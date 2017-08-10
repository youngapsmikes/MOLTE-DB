# MOLTE-DB
MOLTE-DB is a Matlab based modular testing environment for comparing the performances of adaptive learning algorithms on various derivative based stochastic optimization problems. Derivative based stochastic optimization problems are problems in which a gradient (which depends on some random variable) can be computed or approximated. 

MOLTE-DB consists of two main components. 
1. A Matlab based simulator that allows users to compare algorithms by interacting through a spreadsheet based interface. The choice of policies and various parameters is guided through this interface. Users can follow the standard APIs to define new problem classes and new policies by writing a separate .m file. Precoded stochastic optimization problems include the newsvendor problem, maximum likelihood estimation, and a energy storage problem (which includes computing numerical gradients). 

2. Library of derivative based stochastic optimization problems and adaptive learning algorithms represented as functions (GHS, adagrad, BAKF, adam, polynomial learning rate) for stochastic gradient descent. 
