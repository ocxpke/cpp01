#include "Zombie.hpp"

/**
 * @brief Creates a zombie on the stack and makes it announce itself.
 * It is destroyed automatically at the end of the function
 *
 * @param name Name of the zombie
 */
void	randomChump(std::string name)
{
	Zombie	zombie(name);

	zombie.announce();
}
