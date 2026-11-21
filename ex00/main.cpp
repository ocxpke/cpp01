#include "Zombie.hpp"
#include <iostream>

int	main(void)
{
	Zombie	*heapZombie;

	std::cout << "Stack zombie -->" << std::endl;
	/* Properaty scope */
	{
		Zombie	stackZombie("Stacky");

		stackZombie.announce();
	}

	std::cout << "Heap zombie -->" << std::endl;
	heapZombie = newZombie("Heapy");
	heapZombie->announce();
	/* We need to delete heap zombie */
	delete heapZombie;

	std::cout << "randomChump -->" << std::endl;
	randomChump("Chumpy");

	return (0);
}
