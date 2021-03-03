#!/bin/sh
if [ "$1" != "extra" ]; then
curl -s -k https://ncov.moh.gov.vn/ |\
sed -e 's/^[ \t]*//' \
  -n -e '/^<span class="box-vn position-absolute">Việt Nam/,/^<\/div><hr>/p' |\
  sed -e 's/<br> <span class="font24">//g' \
  -e 's/<\/span>//g' \
  -e 's/^<.*$//g' \
  -e '/^[[:space:]]*$/d' \
  -e 's/\r/ /g' \
  -e 's/\.//g' \

elif [ "$1" = "extra" ]; then
cp .local/covid-vn-new .local/covid-vn-old
curl -s -k https://ncov.moh.gov.vn/ |\
sed -e 's/^[ \t]*//' \
  -n -e '/^<span class="box-vn position-absolute">Việt Nam/,/^<\/div><hr>/p' |\
  sed -e 's/<br> <span class="font24">//g' \
  -e 's/<\/span>//g' \
  -e 's/^<.*$//g' \
  -e '/^[[:space:]]*$/d' \
  -e 's/\r/ /g' \
  -e 's/\.//g' \
  -e 's/Số ca nhiễm/ /g' \
  -e 's/Đang điều trị/ /g' \
  -e 's/Khỏi/ /g' \
  -e 's/Tử vong/ /g' |\
  tr '\n' ' a' > .local/covid-vn
cp .local/covid-vn .local/covid-vn-new

nhiemCu=$(awk '{print $2}' .local/covid-vn-old)
dieuTriCu=$(awk '{print $4}' .local/covid-vn-old)
khoiCu=$(awk '{print $6}' .local/covid-vn-old)
chetCu=$(awk '{print $8}' .local/covid-vn-old)

nhiemMoi=$(awk '{print $2}' .local/covid-vn-new)
dieuTriMoi=$(awk '{print $4}' .local/covid-vn-new)
khoiMoi=$(awk '{print $6}' .local/covid-vn-new)
chetMoi=$(awk '{print $8}' .local/covid-vn-new)

nhiemDif=$((nhiemMoi-nhiemCu))
dieuTriDif=$((dieuTriMoi-dieuTriCu))
khoiDif=$((khoiMoi-khoiCu))
chetDif=$((chetMoi-chetCu))

	if [ ! $nhiemDif -eq 0 ]; then
		if [ $nhiemDif -gt 0  ]; then
			dunstify -t 0 "CA NHIỄM MỚI" " +$nhiemDif" && sed -i "s/$nhiemMoi/$nhiemCu +$nhiemDif/g" -e .local/covid-vn
		elif [ $nhiemDif -lt 0 ]; then
			dunstify -t 0 "CA NHIỄM MỚI" " $nhiemDif" && sed -i "s/$nhiemMoi/$nhiemCu $nhiemDif/g" .local/covid-vn
		fi
	fi

	if [ ! $dieuTriDif -eq 0 ]; then
		if [ $dieuTriDif -gt 0  ]; then
			dunstify -t 0 "CA NHẬP VIỆN" " +$dieuTriDif" && sed -i "s/$dieuTriMoi/$dieuTriCu +$dieuTriDif/g" .local/covid-vn
		elif [ $dieuTriDif -lt 0 ]; then
			dunstify -t 0 "CA NHẬP VIỆN" " $dieuTriDif" && sed -i "s/$dieuTriMoi/$dieuTriCu $dieuTriDif/g" .local/covid-vn
		fi
	fi

	if [ ! $khoiDif -eq 0 ]; then
		if [ $khoiDif -gt 0  ]; then
			dunstify -t 0 "CA KHỎI BỆNH" " +$khoiDif" && sed -i "s/$khoiMoi/$khoiCu +$khoiDif/g" .local/covid-vn
		elif [ $khoiDif -lt 0 ]; then
			dunstify -t 0 "CA KHỎI BỆNH" " $khoiDif" && sed -i "s/$khoiMoi/$khoiCu $khoiDif/g" .local/covid-vn
		fi
	fi

	if [ ! $chetDif -eq 0 ]; then
		if [ $chetDif -gt 0  ]; then
			dunstify -t 0 "CA TỬ VONG" " +$chetDif" && sed -i "s/$chetMoi/$chetCu +$chetDif/g" .local/covid-vn
		elif [ $chetDif -lt 0 ]; then
			dunstify -t 0 "CA TỬ VONG" " $chetDif" && sed -i "s/$chetMoi/$chetCu $chetDif/g" .local/covid-vn
		fi
	fi

fi
