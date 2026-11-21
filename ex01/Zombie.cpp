#include "Zombie.hpp"
#include <iostream>

/**
 * @brief Default constructor, needed by new Zombie[N] because
 * it can't pass arguments to each zombie. The name is set later
 */
Zombie::Zombie(void)
{
}

/**
 * @brief Destructor, prints the name of the zombie to see
 * when it is destroyed
 */
Zombie::~Zombie(void)
{
	std::cout << _name << " is destroyed" << std::endl;
}

/**
 * @brief The zombie announces itself
 */
void	Zombie::announce(void) const
{
	std::cout << _name << ": BraiiiiiiinnnzzzZ..." << std::endl;
}

/**
 * @brief Setter of the name, used by zombieHorde after
 * creating the zombies
 *
 * @param name New name of the zombie
 */
void	Zombie::setName(std::string name)
{
	_name = name;
}
