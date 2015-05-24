function i = estimator_information_lookup(infoaddr, i)

s = infoaddr.start(i) + 1;
t = infoaddr.start(i+1);
i = infoaddr.idx(s:t);
