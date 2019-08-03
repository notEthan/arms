# ARMS

ARMS: Active Record Multiple Serialization. This is a library which extends the capabilities of ActiveRecord serialization, allowing you to chain together coders.

For a very simple example, we'll do a thing you can't easily do in ActiveRecord: get a hash with indifferent string/symbol access on the model (in this case for a column named `preferences`), storing serialized JSON in the database:

```ruby
require 'arms'
class Foo < ActiveRecord::Base
  arms_serialize :preferences, :indifferent_hashes, JSON
end
```

assuming you have a database set up with table `foos` and string column `preferences` (see [this script](https://gist.github.com/notEthan/84a4e583ea6e96f0f92dab43286ba301) for a full example), the database will contain JSON (seen with `#preferences_before_type_cast`) and the model attribute offers indifferent access.

```ruby
Foo.create!(preferences: {favorite_animal: 'ocelot'})

foo = foo.last

# JSON in the DB:
foo.preferences_before_type_cast
# => "{\"favorite_animal\":\"ocelot\"}"

# indifferent access on the model:
foo.preferences[:favorite_animal]
# => 'ocelot'
foo.preferences['favorite_animal']
# => 'ocelot'
```

## Coder Shortcuts

With stock ActiveRecord, you can call `serialize :foo, JSON` which is a sort of shortcut to the coder `ActiveRecord::Coders::JSON`. ARMS extends this a bit and offers a registry of shortcuts. In the above example, `:indifferent_hashes` is a shortcut invoking the coder `ARMS::IndifferentHashesCoder`. Most shortcut keys are symbols, but sometimes classes such as JSON or YAML are shortcut keys to coders for those serializations.

Some coders take arguments when they are instantiated. Shortcuts can be expressed as an array, where the first element is the shortcut key and the remainder of the array is passed as arguments to instantiate the coder - for example, the YAML coder can take an argument hinting what class it expects to be serializing. Modifying the above, this would look like:

```ruby
class Foo < ActiveRecord::Base
  arms_serialize :preferences, :indifferent_hashes, [YAML, Hash]
end
```

A full example with this serialization is [at this link](https://gist.github.com/notEthan/297243912fcbd07354fc3d48093df12f).

### Built-in Shortcuts

The following shortcuts are built into ARMS:

| Shortcut Key        | Loads                                               | Dumps                                | Arguments                       | Coder Class                      |
| ---                 | ---                                                 | ---                                  | ---                             | ---                              |
| JSON                | A string of JSON                                    | Ruby Arrays, Hashes, and basic types | none                            | ActiveRecord::Coders::JSON       |
| :json               | ^                                                   | ^                                    | ^                               | ^                                |
| YAML                | A string of YAML                                    | Any                                  | Expected loaded class           | ActiveRecord::Coders::YAMLColumn |
| :yaml               | ^                                                   | ^                                    | ^                               | ^                                |
| :indifferent_hashes | Indifferentiated structure of Arrays and Hashes     | Plain structure of Arrays and Hashes | none                            | ARMS::IndifferentHashesCoder     |
| :struct             | An instance or array of instances of a Struct class | A Hash or Array of Hashes            | The Struct class to instantiate | ARMS::StructCoder                |

## Provided Coders

ARMS offers a few useful coders which may be used with arms_serialize, or with vanilla ActiveRecord::Base.serialize. For the most part these aim to have JSONifiable data on the #dump side, which may be stored in a JSON column or serialized to text with yaml or json.

### ARMS::IndifferentHashesCoder

When loading, this coder takes a JSONifiable structure of arrays and hashes, and will change Hash instances to ActiveSupport::HashWithIndifferentAccess.

When dumping, it converts indifferent hashes to plain hashes.

### ARMS::StructCoder

Instantiated with a Struct class, this converts an instance or instances of that struct to JSONifiable types.

When loading a hash (or array of hashes), the given struct class is instatiated with each member corresponding to a key of a hash.

When dumping, an instance of the specified struct class (or array of instances) is dumped to a hash in which each member of the struct and its value is a key/value pair.

## License

ARMS is open source software available under the terms of the [MIT License](https://opensource.org/licenses/MIT).
