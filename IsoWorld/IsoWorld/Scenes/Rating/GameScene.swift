import SpriteKit

class GameScene: SKScene {

  private var scaleOffset: CGFloat = 1.0
  private var panOffset = CGPointZero
  let viewIso: SKSpriteNode

  var selectedObj: SKSpriteNode?

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let userService = UserService()
  var users = Array<Array<UserScore>>()

  let tileSize = (width: 32, height: 32)

  override init(size: CGSize) {
    viewIso = SKSpriteNode()
    super.init(size: size)
    self.view?.ignoresSiblingOrder = true
    self.backgroundColor = UIColor.whiteColor()

    let scores = userService.loadUserRating()
    users = userService.convertUserScoresToMatrix(fromVector: scores)
  }

  override func didMoveToView(view: SKView) {
    let deviceScale = self.size.width/667
    viewIso.position =  CGPoint(x: 200, y: 200)
    viewIso.xScale = deviceScale
    viewIso.yScale = deviceScale
    addChild(viewIso)

    placeAllTilesIso()
  }

  func point2DToIso(p: CGPoint, inverse: Bool) -> CGPoint {
    // invert y pre conversion
    var point = p * CGPoint(x: 1, y: -1)
    // convert using algorithm
    point =  CGPoint(x: (point.x - point.y), y: ((point.x + point.y) / 2))
    // invert y post conversion
    if !inverse {
      point = point * CGPoint(x: 1, y: -1)
    } else {
      point = point * CGPoint(x: 1, y: -1)
    }
    return point
  }

  func placeTileIso(image: String, withPosition: CGPoint, color: UIColor) -> SKSpriteNode {
    let texture = SKTexture(imageNamed: image)
    let tileSprite = SKSpriteNode(texture: texture)
    tileSprite.position = withPosition
    tileSprite.colorBlendFactor = 1.0
    tileSprite.alpha = 1.0

    if color != UIColor.clearColor() {
      tileSprite.color = color
    } else {
      tileSprite.color = UIColor.yellowColor()
    }

    tileSprite.anchorPoint =  CGPoint(x: 0, y: 0)
    return tileSprite
  }

  func placeAllTilesIso() {
    for i in 0..<users.count {
      let row = users[i]
      for j in 0..<row.count {
        var tileInt = row[j].score

        let column = UserNode()
        column.name =  String(tileInt)
        column.colorBlendFactor = 1.0
        column.alpha = 1.0
        column.color = UIColor.blueColor()

        if tileInt > 1 {
          tileInt = 1
        }

        let tile = Tile(rawValue: tileInt)!

        var color = UIColor.clearColor()

        if row[j].me {
          color = UIColor.redColor()
        } else {
          color = UIColor.clearColor()
        }

        if tileInt > 0 {
          let index = tileSize.height
          let xxx = (j*tileSize.width) + index * 0
          let yyy = -(i*tileSize.height + index  * 0)
          let pointxxx = point2DToIso(CGPoint(x: xxx, y: yyy), inverse: false)
          column.addChild(placeTileIso(("iso_" + tile.image), withPosition: pointxxx, color: color))
          if row[j].score > 1 {
            if j > 0 || i > 0 {
              for indexs in (0..<row[j].score) {
                let xx = (j*tileSize.width) + index * (-indexs)
                let yy = -(i*tileSize.height + index  * (-indexs))
                let pointxx = point2DToIso(CGPoint(x: xx, y: yy), inverse: false)
                column.addChild(placeTileIso(("iso_" + tile.image), withPosition: pointxx, color: color))
              }
            } else {
              for indexs in (1..<row[j].score) {
                let xx = -((j*tileSize.width) + index * indexs)
                let yy = i*tileSize.height + index  * indexs
                let pointxx = point2DToIso(CGPoint(x: xx, y: yy), inverse: false)
                column.addChild(placeTileIso(("iso_" + tile.image), withPosition: pointxx, color: color))
              }
            }
          }
        } else {
          let xxx = (j*tileSize.width) + tileSize.height * 0
          let yyy = -(i*tileSize.height + tileSize.height  * 0)
          let pointxxx = point2DToIso(CGPoint(x: xxx, y: yyy), inverse: false)
          column.addChild(placeTileIso(("iso_" + tile.image), withPosition: pointxxx, color: color))
        }
        
        column.userObj = row[j]
        viewIso.addChild(column)
      }
    }
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      let nodeAtTouch = self.nodeAtPoint(touch.locationInNode(self))
      if let parent = nodeAtTouch.parent as? UserNode {
        if let name = parent.name {
          if Int(name) != nil {
            print(parent.userObj)

            if let selected = selectedObj {
              for element in (selected.children as? [SKSpriteNode])! {
                element.color = UIColor.yellowColor()
              }
            }

            selectedObj = parent

            for element in (parent.children as? [SKSpriteNode])! {
              element.color = UIColor.blueColor()
            }
          }
        }
      }
    }
  }

  func onPinchStart(centroid: CGPoint, scale: CGFloat) {
    scaleOffset = viewIso.xScale
  }

  func onPinchMove(centroid: CGPoint, scale: CGFloat) {
    viewIso.xScale = (scale - 1.0) + scaleOffset
    viewIso.yScale = (scale - 1.0) + scaleOffset
  }

  func onPan(gestureRecognizer: UIPanGestureRecognizer) {
    let y = -(gestureRecognizer.locationInView(self.view).y - self.view!.frame.height)
    let x = gestureRecognizer.locationInView(self.view).x

    self.viewIso.position =  CGPoint(x: x, y: y)
  }

}