#!/usr/bin/perl -w

sub skaiciuokBita()
{
my $Suma = 0;
for(my $k=0;$k<10;$k++)
{
$Suma += $coefBitai[$k]* $bituSeka[$k];
}
$Suma%=2;
return $Suma;


}
# main()
#paversti ivesta teksta bitu seka:
print "Iveskite teksta: ";
$tekstas = <STDIN>;
chomp($tekstas);    # pasaliname \n
@tekstoBitai=();      # bitu masyvas
for ($i=0;$i<length($tekstas);$i++)
{
$k = ord ( substr($tekstas,$i,1)); #simbolio kodas
$raidesKodas = sprintf "%08b",$k; #paverciame i 0,1 eilute
push(@tekstoBitai, split(//,$raidesKodas) );
}
print "\n " ."@tekstoBitai $#tekstoBitai" ;

#
#Generuojame pseudoatsitiktine bitu seka duotajam tekstui sifruoti:
#


$reikes = $#tekstoBitai + 1; # tiek kartu reikes generuoti bitus
#Registrai ir koesficientai

$finish=0;
while (!$finish) {
    print "Iveskite 10 registru reiksmes: ";
    $regs=<STDIN>;
    chomp($regs);

    if ((length($regs)==10)&&(substr($regs,0,1))) {
	$finish=1;
    } else {
	print "Klaida, turi buti 10 registru ir pirmojo reiksme turi buti 1 !\n"
    }
}

$finish=0;
while (!$finish) {
    print "Iveskite 10 koeficientu: ";
    $coef=<STDIN>;
    chomp($coef);

    if ((length($coef)==10)&&(substr($coef,0,1))) {
	$finish=1;
    } else {
	print "Klaida, turi buti 10 koeficientu!\n";
    }

    next;
}

@bituSeka = split ( //,$regs);
@coefBitai = split ( //,$coef);

for( $i=0;$i<$reikes;$i++)
{
$bitas = skaiciuokBita();
unshift(@bituSeka,$bitas);

}
print "\n @bituSeka";


# sifravimas:
@sifras = ();
for($i=0; $i <= $#tekstoBitai; $i++)
{
# naudojame XOR:
push(@sifras, $bituSeka[$i] ^ $tekstoBitai[$i]);

}
print "\n @sifras \n";
