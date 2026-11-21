#include "HumanB.hpp"
#include <iostream>

/**
 * @brief Constructor, HumanB starts without weapon so the
 * pointer is set to NULL
 *
 * @param name Name of the human
 */
HumanB::HumanB(std::string name) : _name(name), _weapon(NULL)
{
}

/**
 * @brief Destructor, the weapon is not owned by the human
 * so nothing is freed
 */
HumanB::~HumanB(void)
{
}

/**
 * @brief Gives a weapon to the human, it stores its address
 *
 * @param weapon Weapon to use
 */
void	HumanB::setWeapon(Weapon &weapon)
{
	_weapon = &weapon;
}

/**
 * @brief Prints the attack with the current type of the weapon,
 * or a message if the human has no weapon
 */
void	HumanB::attack(void) const
{
	if (_weapon == NULL)
		std::cout << _name << " has no weapon" << std::endl;
	else
		std::cout << _name << " attacks with their "
				  << _weapon->getType() << std::endl;
}
