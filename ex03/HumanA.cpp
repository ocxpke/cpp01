#include "HumanA.hpp"
#include <iostream>

/**
 * @brief Constructor, HumanA always has a weapon so it is
 * received here and stored as a reference
 *
 * @note A reference must be set when it is created, so it can
 * only be initialised in the initialization list
 *
 * @param name Name of the human
 * @param weapon Weapon of the human
 */
HumanA::HumanA(std::string name, Weapon &weapon)
	: _name(name), _weapon(weapon)
{
}

/**
 * @brief Destructor, the weapon is not owned by the human
 * so nothing is freed
 */
HumanA::~HumanA(void)
{
}

/**
 * @brief Prints the attack with the current type of the weapon
 */
void	HumanA::attack(void) const
{
	std::cout << _name << " attacks with their "
			  << _weapon.getType() << std::endl;
}
