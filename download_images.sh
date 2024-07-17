wget http://metis.lti.cs.cmu.edu/webarena-images/shopping_final_0712.tar
wget http://metis.lti.cs.cmu.edu/webarena-images/postmill-populated-exposed-withimg.tar
wget http://metis.lti.cs.cmu.edu/webarena-images/gitlab-populated-final-port8023.tar
wget http://metis.lti.cs.cmu.edu/webarena-images/wikipedia_en_all_maxi_2022-05.zim
wget https://zenodo.org/records/12636845/files/openstreetmap-website-db.tar.gz
wget https://zenodo.org/records/12636845/files/openstreetmap-website-web.tar.gz
wget https://zenodo.org/records/12636845/files/openstreetmap-website.tar.gz

tar -xzf openstreetmap-website.tar.gz
mkdir wiki
mv wikipedia_en_all_maxi_2022-05.zim wiki/