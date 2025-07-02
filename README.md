# **DLC** - **D**ynamic **L**o**c**alization for _RAID: World War II_

Have you ever been making a mod for _RAID: World War II_ and found yourself wanting to change your custom localisation strings at runtime without needing to rely on macros or swapping out the string IDs? If so, your mod needs some **DLC** *(Dynamic Localization)*!

## What is *Dynamic Localization*?

### It is *Dynamic*
* Instead of the existing static localization system, in which every localised string is only initialized with a single, unchanging string, _DLC_ rejects this rigid structure, in favour of a flexible, _dynamic_ system of allowing multiple possibilities!
### It is *Local*
* Instead of requiring all mod authors to reimplement the _DLC_ functionality in all their mods (with lots of overhead from all the identical overrides), _DLC_ is intended to be used as a dependency. This allows other mods to make use of it, whilst the busywork of _DLC_ is contained locally.
* _DLC_ is also Local in the sense that it is entirely clientside!
* Furthermore, as _DLC_ is still very niche functionality (for now), containing the functionality of _DLC_ locally within this mod instead of adding it via a PR to SuperBLT prevents it from impacting those who do not want it.
  * That said, _DLC_ will soon enough take the world by storm, and, give or take a few years, every game will proudly announce that it has _DLC_!
### And, but most importantly, it is *Ization*
* For it is the act, the process, and the result of both doing the dynamic and local thing, and of making something dynamically and locally!

## Technical info for mod authors

### What exactly does _DLC_ do?

#### The background context (_RAID-SuperBLT_'s localization system)

<details>
<summary>Here's a recap of the <i>RAID-SuperBLT</i> localization system.</summary>

_RAID-SuperBLT_ itself has a custom `LocalizationManager` class (overriding the base game's instance of it), allowing it to use localization data defined by mod authors (said data is all loaded and added to a `_custom_localization` table, containing key-value pairs of `<string ID (string), localized text (string)>`). So, when a string needs to be localized, it first checks if there's an entry for the ID in the `_custom_localization` table, returning the localized string from there if present (after applying macros on the placeholders in that string) - otherwise, it will fall back on the base game's localization manager (loading the default localization string).

This system works, but it has its drawbacks. Firstly, there is no easy way to change the value of an entry in the `_custom_localization` table - meaning that whatever string was passed to the table upon initialization usually cannot be changed later on without manually re-running a function to replace an entry in the table. Secondly, whilst you *could* try to change strings at runtime via writing a custom macro, it appears that nested macros may not be supported by RAID's internal macro system, and attempting to implement something Wacky™️ like _DLC_ via that system would not be very user-friendly.

</details>

#### Okay, so what does _DLC_ do differently?

The default system only allows one to use Strings as values in the localization table. _DLC_ extends this by allowing the values to be one of *three* datatypes! You can use:

* Strings
  * Same behaviour as in vanilla _RAID-SuperBLT_
* Tables/arrays
  * _DLC_ will pick a value at random from the table, and perform the appropriate action on that value.
* Zero/One-argument functions
  * _DLC_ will run that function each time the localized string needs localization, and will perform the appropriate action on the returned value.
  * (it will pass the original string ID as an argument to that function)

And yes, _DLC_ supports comically-excessive nesting of these datatypes!
* Tables may contain Strings, zero-argument functions, or more tables!
* Zero/One-argument functions may return Strings, tables, or other zero/one-argument functions!
* Any combo works, as long as it eventually returns a String.

#### And how does that benefit mod authors?

Variety is the spice of life. Add some more variety to the UX of your mod via the magic of _DLC_!

### How would one use _DLC_ in their _RAID-SuperBLT_ mod?

**Check out _[Woher kommt Wolfgang?](https://modworkshop.net/mod/51306)_ for an example of DLC in action!**

You can add some DLC functionality to your mod like so:

```lua

local function _someExampleDLCFunction()
  if math.random() > 0.75 then
    return "raid deez nutz lmao gottem"
  end
  return "raid ww2 my beloved"
end

local function _otherExampleDLCFunction(original_id)
  return "I love to ".. original_id .. " in raid ww2!"
end

Hooks:Add("LocalizationManagerPostInit", "Example_DLC_Localization", function(loc)
  LocalizationManager:add_localized_strings({
	  menu_main_title = _someExampleDLCFunction,
	  footer_back = {"My $BTN_CANCEL key broke", "take me home", "no thanks"},
    menu_play = _otherExampleDLCFunction
  })
end)
```

Of course, you still need to add DLC as a dependency to your mod (otherwise things will end badly!)

### How do I add _DLC_ as a dependency to my _RAID-SuperBLT_ mod?

Add this to your mod's `supermod.xml`:

```xml
<dependencies>
  <dependency
    name="DLC - Dynamic Localization"
    meta="https://github.com/11BelowStudio/RAID-DynamicLocalization/releases/latest/download/meta.json"
    download_url="https://github.com/11BelowStudio/RAID-DynamicLocalization/releases/latest/download/RAID-DynamicLocalization.zip"
  /> 
</dependencies>
```

### Do I need to give credit or anything if I make a mod which uses _DLC_ as a dependency?

**RAID-DynamicLocalization** *(DLC)* is released under the MIT license - so you don't _need_ to faff around with credit or license malarkey if you just add *DLC* as a dependency to your mod (the malarkey only happens if you were to directly include *DLC*'s functionality within your mod).

That said, you are encouraged to take pride in your choice of dependencies, and announce to the whole world that your mod contains **DLC**!
