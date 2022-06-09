#include <Kripke/Core/DataStore.h>
#include <Kripke/Generate.h>
#include <Kripke/InputVariables.h>


int main() {
    InputVariables vars;
    Kripke::Core::DataStore data_store;
    Kripke::generateProblem(data_store, vars);

    return 0;
}