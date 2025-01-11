## ***Exercise 2.3: Evaluate the vendor market***

Research and find other platforms in the Cloud Native Ecosystem that meet the criteria in 2.2.1 of being flexible, extensible, and avoiding vendor lock-in.

Hint: They don’t necessarily have to be open source to meet these criteria\!

### **Solution**

Tools in this space are hitting the market with such frequency that an internet search like “platform engineering”, “engineering platforms”, or “internal developer platforms” will return different results almost daily.  It’s important to keep up with what is new to the market because something you’ve been planning to build may have a commercial option.

As of the time of this writing, a suitable tool could be **Prometheus**.  It meets the criteria as follows:

Flexible: Prometheus can be installed on a kubernetes cluster, physical or virtual machine, or be hosted at a service provider

Extensible: Prometheus is heavily configurable, and ingestion can be defined using it’s APIs or through kubernetes resource definitions

Avoids vendor lock-in: Even if hosted by a provider, changing vendors or moving to a self-hosted option should be seamless.