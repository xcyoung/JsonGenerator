# JsonGenerator
## 根据json生成swift实体类的xcode插件，适配Codable协议

### Rule
由于swift特性，Model的属性无法在json中体现。故需要先将json转换为一个自定义规则：

> let/var:Key:Type(:?:Default)
> - 规则以“:”分割。
> - let/var 属性采用的声明为let或者var。
> - Key 属性名，默认为json中的字段名。
> - Type 属性类型，若属性为自定义类型则以xxxNode展示；若属性为集合则以xxxArrayNode展示。
> - ?   属性是否为缺省值，对应Codable的json解析是否必填的场景。
> - Default 若属性缺省时的默认值。
> - 每类型第一行为类名，类型间以\n隔开


json:
>   {
>       "id": 12345,
>       "title": "abcd"
>   }

rule:
>   """
>   Node
>   let:title:String
>   let:id:Int
>   """

![Rule](./Rule.gif)

### Entry

根据Rule生成实体，若类中存在“:?:Default”声明，会自动加入init(from decoder: Decoder)构造方法，处理默认值场景。

![Entry](./Entry.gif)