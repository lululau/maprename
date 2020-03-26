## Installation

```
$ sudo gem install maprename
```

## Usage

```
Usage: maprename [options]
    -c, --config CONFIG_FILE         Specify config file, defaults to `maprename.yml' in current directory
    -d, --dry                        dry run: only print generated file copy commands,
                                     not execute the generated commands, use this option
                                     for debugging or validating config file
    -h, --help                       Prints this help
```

## Config file example

```yaml
input:
  directory: ./tmp/in/
  pattern: "(.*).txt"
  source: "$1.pdf"
  name_parse:
    method: split
    pattern: "[-_]"
    fields:
      - name: customer_name
        value: "$1"
      - name: raw_trans_no
        value: "$2"
        name_parse:
          method: scan
          pattern: L(.*)
          fields:
            - name: trans_no
              value: "$1"
  content_parse:
    encoding: UTF-8
    fields:
      - name: address
        pattern: "您的地址 ([^:：]+)"
        value: "$1"
      - name: trade_date
        pattern: "交易日期：([0-9-]+)"
        value: "$1"

mapping:
  file: ./tmp/in/mapping.csv
  encoding: UTF-8
  column_separator: ","
  first_line_as_column_defination: false
  columns:
    - name: trans_id
      index: 1
    - name: account_no
      index: 2
  select:
    - keyword_column: trans_id
      keyword_value: trans_no
      select_column: account_no
      name: acct_no

output:
  directory: ./tmp/out/
  filename: "#{trade_date}/#{customer_name}-#{acct_no}-#{address}.pdf"
```

## Config file specification

+ `input`: 和输入文件相关的配置
  + `directory`: 指定输入文件所在的目录
  + `pattern`: 用于在匹配过滤输入文件的正则表达式, 其中的正则表达式分组可以用于 `source` 字段的值的生成
  + `source`: 指定将被拷贝的文件
  + `name_parse`: 关于文件名解析的规则配置
    + `method`: 文件名拆分方式，`split`: 使用指定的分割符分割，`scan`：使用正则表达式进行正则分组匹配
    + `pattern`: 对于 `split` 此字段为分割符，支持正则表达式, 对于 `scan` 此字段为用于分组匹配的正则表达式
    + `fields`: 定义要从文件名拆分出的字段
      + `name`: 将字段值存储到以 `name` 值为名称的变量中，在 `output.filename` 中可以使用 `#{变量名}` 的方法获取此变量的值
      + `value`: 字段值的生成规则，对于 `split` 方式 `$N` 指分割出的数组的第 N 个元素（索引从 1 开始）, 对于 `scan` 方法, `$N` 为第 N 个正则分组匹配的值
      + `name_parse` 是一个递归嵌套的结构，可以对拆分出的外层字段，进一步配置 `name_parse` 使得进一步对字段进行拆分
  + `content_parse`: 若需要从文件内容中抽取值，使用此字段对内容抽取规则进行配置
    + `encoding`: 文件内容的字符编码，默认值为 `UTF-8`, 若文件内容为乱码可以尝试配置此字段的值，常用的值有： `UTF-8`, `GBK`, `UTF-16LE`, `UTF-16BE`
    + `fields`: 定义要从文件内容中抽取的值
      + `name`: 将抽取到的值存储到以 `name` 值为名称的变量中，在 `output.filename` 中可以使用 `#{变量名}` 的方法获取此变量的值
      + `pattern`: 用于对文件内容进行匹配的正则表达式，其中的正则表达式分组可以用于下面 `value` 字段的值的生成
      + `value`: 值的生成规则，`$N` 为第 N 个正则分组匹配的值
+ `mapping`: 映射文件相关的配置, 仅支持 CSV 格式
  + `file`: 映射文件路径
  + `encoding`: 映射文件内容的字符编码，默认值为 `UTF-8`, 若文件内容为乱码可以尝试配置此字段的值，常用的值有： `UTF-8`, `GBK`, `UTF-16LE`, `UTF-16BE`
  + `column_separator`: CSV 的字段分割符, 默认为水平制表符 `\t`
  + `first_line_as_column_defination`: 是否使用 CSV 文件的第一行作为字段的名称, 若设置此字段为 `true`, 将忽略下面 `columns` 配置
  + `columns`: 关于映射文件字段的规则定义
    + `name`: 给字段定义一个名称
    + `index`: 字段的列号（索引从 1 开始）
  + `select`: 定义映射规则
    + `keyword_column`: 使用映射文件中的哪个字段进行匹配比较
    + `keyword_value`: 使用哪个变量的值来和 `keyword_column` 所指定的映射文件中的值进行匹配比较
    + `select_column`: 匹配到映射的行之后，用哪个字段的值作为要存储在 `name` 所指定的变量中的值
    + `name`: 要存储到变量的名称, 在 `output.filename` 中可以使用 `#{变量名}` 的方法获取此变量的值
+ `output`: 和输出文件相关的配置
  + `directory`: 输出的目录
  + `filename`: 输出文件名的生成规则，其中可以包含字符串字面量和 `#{变量名}` 形式的变量取值

## About YAML

YAML 是一种常用的配置文件格式，它以不同层次的缩进来表示配置项之间的从属关系和结构，缩紧所使用的空白字符个数必须是规范的：同一级配置项的缩紧必须相同，第 N 层和第 N+1 层之间的缩进差别必须等于第 N+1 层和 第 N+2 层之间的缩紧差别，一个缩进递进中，推荐使用两个空格作为缩进

以减号开头的配置项表示它的上一级配置项的值是数组类型，每个减号表示数组中的一个元素

See also: Official YAML specification: https://yaml.org/spec/1.2/spec.html

## Getting involved in Regular Expression

正则表达式30分钟入门教程: https://deerchao.cn/tutorials/regex/regex.htm

文中，在学习过程中使用一个 Windows 上的正则表达式测试器来帮助理解，Mac 上可以使用这个 Web 版的正则表达式测试器： https://deerchao.cn/tools/wegester/

Learn Regex the Easy Way: https://github.com/ziishaned/learn-regex/blob/master/translations/README-cn.md

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Maprename project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/lululau/maprename/blob/master/CODE_OF_CONDUCT.md).
