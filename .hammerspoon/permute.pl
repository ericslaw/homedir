#!/usr/bin/perl -l

#https://metacpan.org/release/Math-Permute-List/source/lib/Math/Permute/List.pm

sub permute(&@)    # Generate all permutations of a list
{
    my $s = shift;         # Subroutine to call to process each permutation
    my $n = scalar(@_);    # Size of array to be permuted

    my $l = 0;             # Item being permuted
    my @p = ();            # Current permutations
    my @P = @_;            # Array to permute
    my @Q = ();            # Permuted array

    my $p;
    $p = sub               # Generate each permutation
    {
        if ( $l < $n ) {
            for ( 0 .. $n - 1 ) {
                if ( !$p[$_] ) {
                    $Q[$_] = $P[$l];
                    $p[$_] = ++$l;
                    &$p();              # recurse
                    --$l;
                    $p[$_] = 0;
                }
            }
        } else {
            &$s(@Q);
        }
    };

    &$p;

    $p = undef;    # Break memory loop per Philipp Rumpf

    my $i = 1;
    $i *= $_ for 2 .. $n;
    $i             # Number of permutations
}

permute( sub {
    print
        join" ",
        map {
            my $list=$_;
            join"", map {substr $list,$_,1} @_
        }
        qw( ^>v< nesw urdl ilkj kljh )
}, 0 .. 3 )

__DATA__
+   ^>v< NESW urdl ilkj kljh
?   <^v> wnse ludr jikl hkjl
+   <v^> wsne ldur jkil HJKL
+   ^v<> nswe UDLR ikjl kjhl
+   ^<v> nwse uldr IJKL khjl
    ^><v news urld iljk klhj
    ^v>< nsew udrl iklj kjlh
    ^<>v nwes ulrd ijlk khlj
    >^v< ensw rudl likj lkjh
    >^<v enws ruld lijk lkhj
    v^>< snew durl kilj jklh
    <^>v wnes lurd jilk hklj
    v^<> snwe dulr kijl jkhl
    >v^< esnw rdul lkij ljkh
    ><^v ewns rlud ljik lhkj
    v>^< senw drul klij jlkh
    <>^v wens lrud jlik hlkj
    v<^> swne dlur kjil jhkl
    >v<^ eswn rdlu lkji ljhk
    ><v^ ewsn rldu ljki lhjk
    v><^ sewn drlu klji jlhk
    <>v^ wesn lrdu jlki hljk
    v<>^ swen dlru kjli jhlk
    <v>^ wsen ldru jkli hjlk
