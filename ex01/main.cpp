#include "Zombie.hpp"
#include <iostream>

int	main(void)
{
	Zombie	*horde;
	int		n;

	n = 5;
	std::cout << "Horde of " << n << " zombies" << std::endl;
	horde = zombieHorde(n, "Walker");
	for (int i = 0; i < n; i++)
		horde[i].announce();
	/* Calls n times the destructor, one per zombie, and frees arr mem*/
	delete[] horde;

	std::cout << "Horde of 0 zombies" << std::endl;
	horde = zombieHorde(0, "Nobody");
	if (horde == NULL)
		std::cout << "No horde created" << std::endl;
	/* No message shall be printed after this delete*/
	delete[] horde;

	return (0);
}
