import numpy as np
import time
import json
import sys

np.random.seed(42)


def run(param_str: str) -> str:
    """Run the Ackely function on the specified JSON
    payload.

    Return:
        The Ackley function result as a JSON formatted string.
    """
    args = json.loads(param_str)
    x = np.array(args['x'])

    result = ackley(x)
    # print(f'Result: {result}', flush=True)
    return json.dumps(result)


def ackley(x: np.array, a=20, b=0.2, c=2 * np.pi, mean_rt=1, std_rt=0.5) -> np.float64:
    """The Ackley function (http://www.sfu.ca/~ssurjano/ackley.html)
    Args:
        x (ndarray): Points to be evaluated. Can be a single or list of points
        a (float): Parameter of the Ackley function
        b (float): Parameter of the Ackley function
        c (float): Parameter of the Ackley function
        mean_rt (float): ln(Mean runtime in seconds)
        std_rt (float): ln(Standard deviation of runtime in seconds)
    Returns:
        y (ndarray): Output of the Ackley function
    """
    # Simulate this actually taking awhile
    runtime = np.random.lognormal(mean_rt, std_rt)
    time.sleep(runtime)

    # Get the dimensionality of the problem
    if x.ndim == 0:
        x = x[None, None]
    elif x.ndim == 1:
        x = x[None, :]
    d = x.shape[1]
    y = - a * np.exp(-b * np.sqrt(np.sum(x ** 2, axis=1) / d)) - np.exp(np.cos(c * x).sum(axis=1) / d) + a + np.e
    return y[0]


if __name__ == '__main__':
    # param_line, output_file
    param_str = sys.argv[1]
    output_file = sys.argv[2]

    y = run(param_str)
    with open(output_file, 'w') as fout:
        fout.write(f'{y}')
