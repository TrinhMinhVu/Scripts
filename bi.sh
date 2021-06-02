#!/bin/bash
case "$1" in
	"-b")
		case "$3" in
			"-h")
				echo "Binary $2 to hexadecimal is:"
				echo "obase=16; ibase=2; $2" | bc

				;;
			*)
				echo "Binary $2 to decimal is:"
				echo "obase=10; ibase=2; $2" | bc
				;;
		esac
		;;
	"-d")
		case "$3" in
			"-h")
				echo "Decimal $2 to hexadecimal is:"
				echo "obase=16; ibase=10; $2" | bc

				;;
			*)
				echo "Decimal $2 to binary is:"
				echo "obase=2; ibase=10; $2" | bc
				;;
		esac
		;;
	*)
		echo -e "Usage:\tbi.sh -b 01101001 -d\nto convert binary '01101001' to decimal\n\tbi.sh -d 105 -b\nto convert decimal '105' to binary"
		;;
esac
