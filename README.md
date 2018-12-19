# macOS Cocoa License Key Control

![](./art/simple.png)

![](./art/preview.gif)

### Configurable in IB and via code

* Number of license segments
* Number of characters in a segment
* Placeholder character
* (Optional) Highlighting if the licence key is invalid

## Usage

### Read-only

#### Objective-C

    [DSFLicenseKeyControlView createWithName:@"Eight by Three License Key"
                                segmentCount:3
                                 segmentSize:8
                                         key:@"ABCDEFGH-IJKLMNOP-QRSTUVWX"];

#### Swift

    DSFLicenseKeyControlView.create(withName: "Eight by Three License Key",
                                    segmentCount: 3,
                                    segmentSize: 8,
                                    key: "ABCDEFGH-IJKLMNOP-QRSTUVWX")

### Mutable (editable)

#### Objective-C

    [DSFMutableLicenseKeyControlView createMutableWithName:@"Four by Six License Key"
                                              segmentCount:4
                                               segmentSize:6
                                                       key:@"123456-ABCDEF-CATDOG-NOODLE"];

#### Swift

     DSFMutableLicenseKeyControlView.createMutable(withName: "Four by Six License Key",
                                                   segmentCount: 4,
                                                   segmentSize: 6,
                                                   key: "123456-ABCDEF-CATDOG-NOODLE")

### Integration with Interface Builder

These provide interface builder inspectables, so that you can :-

1. Configure your license key field within IB
2. Preview your license key directly in your view

![](./art/interface_builder.png)

### Preview your license key

Use Interface Builder to build your views live

![](./art/interface_builder_preview.png)

## Keyboard navigation

* Tab between the fields in your license key
* When a field is filled, moves automatically to the next field

![](./art/keyboard_navigation.gif)

## Paste support

You can copy and paste your license key into a field, and if the copied key matches the settings, will properly fill the fields

![](./art/paste_support.gif)

## Voiceover support

Comes with Voiceover support out-of-the-box, meaning that your visually impaired users can use your app straight away.

## Acknowlegements

Uses [`RSVerticallyCenteredTextFieldCell`](https://red-sweater.com/blog/148/what-a-difference-a-cell-makes) by Daniel Jalkut of Red Sweater Software 
