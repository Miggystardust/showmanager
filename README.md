TroupeIt Show Manager
=====================

TroupeIT is a collaboration tool for managing a stage show. We use it primarily to manage the Hubba Hubba Revue at the DNA Lounge and other bay area venues. We're a Burlesque troupe, so our use case may be very different from yours, but you can use the software easily to manage a school or community theater. 

Our shows largely consist of people performing to prerecorded music. This system allows the performer to upload their music to the system and specify their "Act". After that, a stage manager creates a "Show" and adds the "Acts" to the "Show". 

Other personnell, benefit from the system in many ways once a show has been created...

* The sound techs, can download the show as a single ZIP file for playback (I usually use Figure53's qLab for this purpose)
* Lighting and Stage cues are right there on the Live view screen
* Stage managers can print backstage schedules with the "LIST" view.
* The MC/Announcer notes are available in the LIST view via "Show MC Notes"
* During the show, the MARK feature on the LIVE VIEW can be used to synchronize everyone together so people know where the show is at.

Best of all, it's good for the environment because performers don't have to burn single-use CD-Rs for their music.

Dependencies
============
Tested under Phusion Passenger, Rails 4.0.9,  Ruby 2.1.3p242 , nginx 1.62, and mongoDB 2.0.7-rc0
This project is largely based on rails3-mongoid-devise for authentication. 
It also uses Bootstrap3 extensively for layout (getbootstrap.com)

Installation
============

1. Start up Mongo locally on standard ports
2. Adjust config/environments as needed for your environemnt
3. In the app's root dir, do a 'bundle install' to install all the gems. 
4. Start the app under either ruby script/rails server, nginx+passenger, or apache+passenger.

Configuring a webserver to work with Rails is beyond the scope of this
documentation. You should consult the appropriate sites and Phusion
Passenger documentation.

Initialization
===============

Because we're using roles, we need to seed the database before we can 
start. do:

```
   export RAILS_ENV=production
   rake db:seed
```

NOTE: running rake db:seed will DROP THE DATABASE, so never run this
task against a production system.

It will also generate a random 8 character password and an admin account
which you can use to set things up.

Public Domain Dedication
========================

This work is a compilation and derivation from other previously
released works. With the exception of various included works, which
may be restricted by other licenses, the author or authors of this
code dedicate any and all copyright interest in this code to the
public domain. We make this dedication for the benefit of the public
at large and to the detriment of our heirs and successors. We intend
this dedication to be an overt act of relinquishment in perpetuity of
all present and future rights to this code under copyright law.

Open Source
-----------

Devise and OmniAuth are the primary authentication mechnanisms in this
code, starting with the base package:
http://github.com/railsapps/rails3-mongoid-devise

This software makes extensive use of DataTables for JQuery and the
plugins TableTools, Row reordering, and others.
http://www.datatables.net/download/

Released under the Apache Open Source License.
