
/* TEST EQR 1
   Assumes running on 4 ranks, resident task on rank 2
   Expected output: 'state: 0', because we did not initialize EQ/R,
   but this does call into the C++ module.
 */

import io;
import location;
import EQR;

printf("EQ/R state: %b", EQR_is_initialized(rank2location(2)));
