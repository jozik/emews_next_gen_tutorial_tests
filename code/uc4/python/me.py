import argparse
from typing import Dict
import numpy as np
import json
from dataclasses import dataclass

import scipy
from sklearn.gaussian_process import GaussianProcessRegressor, kernels
from sklearn.preprocessing import MinMaxScaler
from sklearn.pipeline import Pipeline

from eqsql import worker_pool, db_tools, cfg
from eqsql.task_queues import local_queue
from eqsql.task_queues import core


@dataclass
class Task:
    future: core.Future
    sample: np.array
    result: float


def submit_initial_tasks(task_queue, exp_id: str, params: Dict) -> Dict[int, Task]:
    """Submits the initial parameters to the task queue for evaluation

    args:
        task_queue:
        exp_id:
        params:
    """
    search_space_size = params['search_space_size']
    dim = params['sample_dimensions']
    sampled_space = np.random.uniform(size=(search_space_size, dim), low=-32.768, high=32.768)

    task_type = params['task_type']

    payloads = []
    for sample in sampled_space:
        payload = json.dumps({'x': list(sample)})
        payloads.append(payload)
    _, fts = task_queue.submit_tasks(exp_id, eq_type=task_type, payload=payloads)

    tasks = {ft.eq_task_id: Task(future=ft, sample=sampled_space[i], result=None)
             for i, ft in enumerate(fts)}

    return tasks


def fit_gpr(training_data, pred_data):
    gpr = Pipeline([('scale', MinMaxScaler(feature_range=(-1, 1))),
                    ('gpr', GaussianProcessRegressor(normalize_y=True, kernel=kernels.RBF() * kernels.ConstantKernel()))
                    ])
    train_x, train_y = zip(*training_data)
    # fit grp with completed tasks results
    gpr.fit(np.vstack(train_x), train_y)

    pred_y, pred_std = gpr.predict(pred_data, return_std=True)
    best_so_far = np.min(train_y)
    ei = (best_so_far - pred_y) * scipy.stats.norm(0, 1).cdf((best_so_far - pred_y) / pred_std) + pred_std * \
          scipy.stats.norm(0, 1).pdf((best_so_far - pred_y) / pred_std)

    return np.argsort(-1 * ei)


def reprioritize(task_queue, tasks: Dict[int, Task]):
    # separate tasks into training and prediction data
    training = []
    uncompleted_fts = []
    prediction = []
    for t in tasks.values():
        if t.result is None:
            uncompleted_fts.append(t.future)
            prediction.append(t.sample)
        else:
            training.append([t.sample, t.result])

    if len(uncompleted_fts) > 0:
        fts = []
        priorities = []
        max_priority = len(uncompleted_fts)
        ranking = fit_gpr(training, prediction)
        for i, idx in enumerate(ranking):
            ft = uncompleted_fts[idx]
            priority = max_priority - i
            fts.append(ft)
            priorities.append(priority)

        print("Reprioritizing ...", flush=True)
        task_queue.update_priorities(fts, priorities)


def run(exp_id: str, params: Dict):
    db_started = False
    pool = None
    task_queue = None
    try:
        # start database
        db_tools.start_db(params['db_path'])
        db_started = True

        # start task queue
        task_queue = local_queue.init_task_queue(params['db_host'], params['db_user'],
                                                 port=None, db_name=params['db_name'])

        # check if the input and output queues are empty,
        # if not, then exit with a warning.
        if not task_queue.are_queues_empty():
            print("WARNING: db input / output queues are not empty. Aborting run", flush=True)
            return

        # start worker pool
        pool_params = worker_pool.cfg_file_to_dict(params['pool_cfg_file'])
        pool = worker_pool.start_local_pool(params['worker_pool_id'], params['pool_launch_script'],
                                            exp_id, pool_params)

        tasks = submit_initial_tasks(task_queue, exp_id, params)
        total_completed = params['total_completed']
        tasks_completed = 0
        reprioritize_after = params['reprioritize_after']
        # list of futures for the submitted tasks
        fts = [t.future for t in tasks.values()]

        while tasks_completed < total_completed:
            # add the result to the completed Tasks.
            for ft in task_queue.as_completed(fts, pop=True, n=reprioritize_after):
                _, result = ft.result()
                tasks[ft.eq_task_id].result = json.loads(result)
                tasks_completed += 1

            reprioritize(task_queue, tasks)

    finally:
        if task_queue is not None:
            task_queue.close()
        if pool is not None:
            pool.cancel()
        if db_started:
            db_tools.stop_db(params['db_path'])


def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('exp_id', help='experiment id')
    parser.add_argument('config_file', help="yaml format configuration file")
    return parser


if __name__ == '__main__':
    parser = create_parser()
    args = parser.parse_args()
    params = cfg.parse_yaml_cfg(args.config_file)

    run(args.exp_id, params)
