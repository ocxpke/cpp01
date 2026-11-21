#include "Zombie.hpp"
#include <iostream>

/**
 * @brief Zmbie Constructor
 *
 * @param name Name of the zombie
 */
Zombie::Zombie(std::string name) : _name(name)
{
}

/**
 * @brief Zombie destructor
 * @note prints the name of the zombie to see when it is
 * destroyed
 */
Zombie::~Zombie(void)
{
	std::cout << _name << " is destroyed" << std::endl;
}

/**
 * @brief Zombie message
 */
void	Zombie::announce(void) const
{
	std::cout << _name << ": BraiiiiiiinnnzzzZ..." << std::endl;
}
