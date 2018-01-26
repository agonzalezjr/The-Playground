import UIKit
import PlaygroundSupport

func hello()
{
    print("Hello, World")
}

let container = UIView(frame: CGRect(x: 0, y: 0, width: 800, height: 150 * 5))

let song: [String] = [
"""
And all your touch and all you see
Is all your life will ever be
""",
"""
Run, rabbit run
Dig that hole, forget the sun
""",
"""
And when at last the work is done
Don't sit down, it's time to dig another one
""",
"""
For long you live and high you fly
But only if you ride the tide
""",
"""
And balanced on the biggest wave
You race towards an early grave
""" ]

func addLabel(_ container: UIView,
              _ i: Int,
              _ color: UIColor,
              _ alignment: NSTextAlignment) {
    let label = UILabel(frame: CGRect(x: 0, y: 150 * i, width: 800, height: 150))
    label.backgroundColor = color
    
    let text = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer faucibus eu tortor non vulputate. Sed a arcu porta, facilisis velit sit amet, eleifend sem. Aliquam venenatis felis ut ullamcorper dignissim. Vestibulum elementum rhoncus congue. Cras lacinia metus non nibh egestas elementum. Quisque tincidunt placerat dui ac sollicitudin.
"""
    
    label.text = text
    label.numberOfLines = 0
    label.textAlignment = alignment
    container.addSubview(label)
}

addLabel(container, 0, .red, .center)
addLabel(container, 1, .yellow, .justified)
addLabel(container, 2, .green, .left)
addLabel(container, 3, .blue, .natural)
addLabel(container, 4, .orange, .right)

PlaygroundPage.current.liveView = container
PlaygroundPage.current.needsIndefiniteExecution = true
