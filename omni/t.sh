echo "Running ruby tomni.rb"
cd html
if test -d omniresults
then
    echo "html/omniresults already exists"
else
    echo "creating html/omniresults"
    mkdir omniresults
fi
cd ..
if test -d /media/ramdisk
then
    echo "/media/ramdisk/r already exists"
    if test -d /media/ramdisk/rapfp
    then
	echo "/media/ramdisk/rapfp already exists" 
    else
	echo "creating /media/ramdisk/rapfp"
	cp -r rapfp /media/ramdisk
    fi
fi
ruby tomni.rb
