#include "Zombie.hpp"
#include <cstddef>

/**
 * @brief Creates N zombies in a single allocation and gives
 * each of them the same name
 *
 * @note new Zombie[N] calls the default constructor N times,
 * so the names are set after with setName. The caller has to
 * free the horde with delete[]
 *
 * @param N Number of zombies
 * @param name Name for all the zombies
 * @return Zombie* Pointer to the first zombie, NULL if N <= 0
 */
Zombie	*zombieHorde(int N, std::string name)
{
	Zombie	*horde;

	if (N <= 0)
		return (NULL);
	horde = new Zombie[N];
	for (int i = 0; i < N; i++)
		horde[i].setName(name);
	return (horde);
}
