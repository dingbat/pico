import itertools

permutations = list(itertools.permutations(range(4), 2))


    

for perm in itertools.permutations([0,0,0,1,1,1,2,2,2,3,3,3]):
    for i in range(len(perm)):
        if perm[i] == perm[(i+1)%12] or perm[i] == perm[(i+2)%12]:
            break
    else:
        s=''.join([str(num) for num in perm])
        for pair in permutations:
          s2=''.join([str(num) for num in pair])
          if not s2 in s+s:
            break
        else:
         print(s)