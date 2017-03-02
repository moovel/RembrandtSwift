# About

RembrandtSwift is an image comparison library for swift 3 with objective-C bindings, based on Rembrandt**JS** see http://rembrandtjs.com. We created Rembrandt to have an easy-to-use image comparison library for our internal tests for [PhotoEditor SDK] (www.photoeditorsdk.com/?utm_campaign=Projects&utm_source=Github&utm_medium=Side_Projects&utm_content=Rembrandt&utm_term=iOS). 

## Installation
### CocoaPods
Here's what you have to add to your Podfile:

```
use_frameworks!

target '<your product here>' do
  pod 'rembrandt', :path => '../'
end

```
## Usage
```swift
let imageA = UIImage(named: "imageA")
let imageB = UIImage(named: "imageB")
let rembrandt = Rembrandt()
let result = rembrandt.compare(imageA: imageA!, imageB: imageB!)
```

![](./result.png)

## License

### The MIT License (MIT)

Copyright © `2016` `imgly`

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the “Software”), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
