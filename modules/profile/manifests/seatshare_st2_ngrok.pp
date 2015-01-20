class profile::seatshare_st2_ngrok {
  class { 'ngrok':
    port      => '9101',
    subdomain => 'cicdtest',
    httpauth  => 'cicd:isthebest',
  }
}
