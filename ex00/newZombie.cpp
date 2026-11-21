#include "Zombie.hpp"

/**
 * @brief Creates a zombie on the heap, so it keeps existing
 * outside of this function
 *
 * @note The caller has to delete it when it is not needed anymore
 *
 * @param name Name of the zombie
 * @return Zombie* Pointer to the new zombie
 */
Zombie	*newZombie(std::string name)
{
	return (new Zombie(name));
}
