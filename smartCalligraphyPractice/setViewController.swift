//
//  setViewController.swift
//  smartCalligraphyPractice
//
//  Created by 羅琮棠 on 2023/10/30.
//

import UIKit
struct imagedata: Codable {
    let data: [String]
}
protocol setViewdelegat: AnyObject {
    func setvalue(_ controller: setViewController,wordlengt:CGFloat,colnum:Int,words:[String],flag:Bool,strokefalg:Bool,label:Int,color:StrokeColor,blendLabel:Int?,blendRatio:Float)
}
class setViewController: UIViewController, UITextFieldDelegate,UIColorPickerViewControllerDelegate {
    
    var wordstylebar:UIToolbar!
    var nowwordstytle:UILabel!
    var wordstyle:UIPickerView!
    var wordstyletext:UILabel!
    var wordstytleTextField: UITextField!
    var wordstylebutton:UIButton!
    var wordstyleblenderratio:UISlider!
    var wordstyleblenderratiotext:UILabel!
    var blenderstyle:UIButton!
    var wordlengthslider:UISlider!
    var wordlengthstext : UILabel!
    var sampleTextField : UITextField!
    var wantWordText: UILabel!
    var wantWordstytleText: UILabel!
    var colnumslider:UISlider!
    var colnumtext:UILabel!
    @objc var confirmButton:UIButton!
    var rowwordnum:Int = 8
    var colwordnum:Int = 12
    var wordlength:CGFloat = 75
    var goalStrings:[String] = []
    var goalString:String = "測試文字測試文字"
    var goalwordimagebase64:[String] = []
    // 舊版這裡有個 IP:String（區網 IP，指向舊版 http.server）——網址跟
    // API Key 現在集中在 APIConfig.swift，這邊不用再存一份。
    var switchControltext:UILabel!
    var switchControl : UISwitch!
    var strokeControltext : UILabel!
    var strokeControl : UISwitch!
    var changecolor:UIButton!
    var showFormFlag=true
    var showStroke=true
    var nowstyle:Int=0
    var blenderstytle:String="無"
    var blenderstytleindex:Int = 0
    var rationum:Float = 0.0
    var strokecolor:UIColor?
    var strokecolorInts:[Int]=[0,0,0,255]
    /// 送出中旗標：避免「確認設定」被連點而同時發出多個 /synthesize 請求。
    private var isSubmitting = false
    weak var delegate:setViewdelegat!
    let style = ["原創","原創二值化", "衡山毛筆", "雁宇落雁","青松手寫","Dengxian","大陸宋體","fzshuti","漢儀新帝永樂大典","微軟正黑體","教育部隸書","王漢中行書","新帝竹林體","仿宋體","中易黑體","漢儀新蒂唐朝體","华文仿宋","STSong","隨峰體","宋體","小賴字體","標楷體"]
    let blender = ["無","原創","原創二值化", "衡山毛筆", "雁宇落雁","青松手寫","Dengxian","大陸宋體","fzshuti","漢儀新帝永樂大典","微軟正黑體","教育部隸書","王漢中行書","新帝竹林體","仿宋體","中易黑體","漢儀新蒂唐朝體","华文仿宋","STSong","隨峰體","宋體","小賴字體","標楷體"]
//    =" 想要練的字"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        wordstyle=UIPickerView()
        wordstylebar=UIToolbar()

        wantWordText=UILabel()
        sampleTextField=UITextField()
        nowwordstytle=UILabel()
        wordstylebutton=UIButton()
        wordstyleblenderratiotext=UILabel()
        wordstyleblenderratio=UISlider()
        colnumtext=UILabel()
        colnumslider=UISlider()
        wordlengthstext=UILabel()
        wordlengthslider=UISlider()
        switchControltext=UILabel()
        switchControl=UISwitch()
        strokeControltext=UILabel()
        strokeControl=UISwitch()
        changecolor=UIButton()
        confirmButton=UIButton()
        wordstytleTextField=UITextField()

        setuptextfield()
        setupwordlengthslide()
        setupcolnumslide()
        setupconfirmButton()
        setupwordstyle()
        setupwordstyleblenderratio()
        setupSwitcher()
        layoutContent()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setViewController.dismissKeyboard))
        // cancelsTouchesInView 預設是 true，加在 self.view 上的 tap gesture 會
        // 把底下 UIButton 的 touch 吃掉，導致 .touchUpInside 收不到——這也是
        // 原本所有按鈕只能用 .touchDown 的原因。關掉它之後按鈕才能改回
        // 標準的 .touchUpInside（按下去再放開才算，拖開可取消、不會連點誤觸）。
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    /// 原本每個控制項都是「螢幕中心 + 固定像素偏移」算出來的 CGRect（例如
    /// wordstyleblenderratiotext 寬 600、strokeControl 要 viewwidth/2+150
    /// 才放得下），這是照寬螢幕估的，實際用設定圖示叫出來時 view 是手機
    /// 寬度，越靠右的控制項（changecolor、strokeControl）就越容易被切掉、
    /// 甚至完全跑到畫面外。改成 UIStackView + Auto Layout，每一排都用
    /// 實際的 view 寬度自動排列、超出高度會自動捲動，不用再手算像素。
    private func layoutContent() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        view.addSubview(wordstytleTextField)
        wordstytleTextField.isHidden = true

        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        [wantWordText, sampleTextField, nowwordstytle, wordstylebutton,
         wordstyleblenderratiotext, wordstyleblenderratio,
         colnumtext, colnumslider, wordlengthstext, wordlengthslider].forEach { v in
            v.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
            contentStack.addArrangedSubview(v)
        }

        let switchRow = UIStackView(arrangedSubviews: [
            labeledSwitchRow(switchControltext, switchControl),
            labeledSwitchRow(strokeControltext, strokeControl),
            changecolor
        ])
        switchRow.axis = .horizontal
        switchRow.alignment = .center
        switchRow.distribution = .equalSpacing
        changecolor.widthAnchor.constraint(equalToConstant: 40).isActive = true
        changecolor.heightAnchor.constraint(equalToConstant: 40).isActive = true
        contentStack.addArrangedSubview(switchRow)

        confirmButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        contentStack.addArrangedSubview(confirmButton)
    }
    private func labeledSwitchRow(_ label: UILabel, _ switchView: UISwitch) -> UIView {
        let row = UIStackView(arrangedSubviews: [label, switchView])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }

    func setupwordstyle(){
        nowwordstytle.font = UIFont.systemFont(ofSize: 20)
        nowwordstytle.textColor = UIColor.black
        nowwordstytle.text="目前字體:"+style[0]
        wordstylebutton.configuration = .filled()
        wordstylebutton.configuration?.baseBackgroundColor = .systemBlue
        wordstylebutton.configuration?.title = "更改字體&混合字體"
        
        wordstylebutton.addTarget(self, action: #selector(openstylepicker), for: .touchUpInside)
        let cancelbutton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelstylepicker))
        let spacebutton=UIBarButtonItem(systemItem: .flexibleSpace)
        let changebutton = UIBarButtonItem(title: "更改", style: .plain, target:self, action: #selector(closestylepicker))
        wordstylebar.setItems([cancelbutton,spacebutton,changebutton], animated: true)
        wordstylebar.translatesAutoresizingMaskIntoConstraints = false
//        wordstylebar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        wordstylebar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        wordstylebar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        wordstyle.dataSource = self
        wordstyle.delegate = self
        wordstytleTextField.inputAccessoryView = wordstylebar
        wordstytleTextField.inputView = wordstyle
        
        
    }
    func setupwordstyleblenderratio(){
        wordstyleblenderratiotext.numberOfLines = 0
        wordstyleblenderratiotext.font = UIFont.systemFont(ofSize: 20)
        wordstyleblenderratiotext.textColor = UIColor.black
        wordstyleblenderratiotext.text="目前混合比率:"+String(rationum)+"目前混合字體:"+blenderstytle
        wordstyleblenderratio.maximumValue=1
        wordstyleblenderratio.minimumValue=0
        wordstyleblenderratio.setValue(0, animated: true)
        wordstyleblenderratio.addTarget(self, action: #selector(wordstyleblenderratioChange(_:)), for: .valueChanged)
        wordstyleblenderratio.isContinuous = true
//        blenderstyle.configuration = .filled()
//        blenderstyle.configuration?.baseBackgroundColor = .systemBlue
//        blenderstyle.configuration?.title = "選擇混合字體"
    }
    func setuptextfield(){
        wantWordText.text="想練的字"
        wantWordText.font = UIFont.systemFont(ofSize: 20)
        wantWordText.textColor=UIColor.black
        sampleTextField.placeholder = "Enter text here"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.borderStyle = UITextField.BorderStyle.roundedRect
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        sampleTextField.delegate = self
        // 原本 goalString 只有在 textFieldShouldReturn（鍵盤右下角 Done）
        // 才會被寫入，所以「打完字直接按確認設定」或「點空白處收鍵盤」、
        // 「按更改字體讓 picker 搶走 first responder」這幾種收鍵盤的路徑都
        // 會繞過它，送出的其實是上一次的（或預設的「測試文字測試文字」）
        // ——這就是客製化想練的字「有時成功有時失敗」的主因。改成邊打邊同步，
        // 收鍵盤的方式就不再影響結果。
        sampleTextField.addTarget(self, action: #selector(goalTextChanged(_:)), for: .editingChanged)
    }
    @objc func goalTextChanged(_ sender: UITextField) {
        goalString = sender.text ?? ""
    }
    func setupwordlengthslide(){
        wordlengthslider.maximumValue=120
        wordlengthslider.minimumValue=20
        wordlengthslider.setValue(75, animated: true)
        wordlengthslider.addTarget(self, action: #selector(wordlengthsliderValueChanged(_:)), for: .valueChanged)
        wordlengthstext.font = UIFont.systemFont(ofSize: 20)
        wordlengthstext.textColor = UIColor.black
        wordlengthstext.text = "目前練字框大小："+String(wordlengthslider.value)
        
    }
    func setupcolnumslide(){
        colnumslider.maximumValue=12
        colnumslider.minimumValue=2
        colnumslider.setValue(7, animated: true)
        colnumslider.addTarget(self, action: #selector(colnumsliderValueChanged(_:)), for: .valueChanged)
        colnumtext.font = UIFont.systemFont(ofSize: 20)
        colnumtext.textColor = UIColor.black
        colnumtext.text = "目前練字框數目："+String(Int(colnumslider.value))
        
    }
    func setupconfirmButton(){
        confirmButton.configuration = .filled()
        confirmButton.configuration?.baseBackgroundColor = .systemBlue
        confirmButton.configuration?.title = "確認設定"
        confirmButton.addTarget(self, action: #selector(returndata), for: .touchUpInside)
    }
    func setupSwitcher(){
        switchControltext.text="字帖模式"
        strokeControltext.text="筆畫預測"
        strokeControl.isOn = true
        switchControl.isOn = true
        switchControl.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        strokeControl.addTarget(self, action: #selector(strokeChanged(_:)), for: .valueChanged)
        changecolor.configuration = .filled()
        changecolor.configuration?.baseBackgroundColor = .systemBlue
        changecolor.configuration?.image=UIImage(systemName:"paintpalette")
        changecolor.addTarget(self, action: #selector(tapcolorpicker), for: .touchUpInside)
    }
    @objc func tapcolorpicker(){
        let colorPickerVC=UIColorPickerViewController()
        colorPickerVC.isModalInPresentation=true
        colorPickerVC.delegate=self
        present(colorPickerVC,animated: true)
        
        
    }
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color=viewController.selectedColor
        strokecolorInts=color.toRGBA()
        transmitcolor()
    }
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        
    }
    @objc func wordstyleblenderratioChange(_ sender: UISlider){
        let discreteValues: [Float] = [0,0.1, 0.15, 0.2, 0.25, 0.3, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.95,1.0] // 定義分段的值
        let value = sender.value
        let roundedValue = roundValue(value: value, discreteValues: discreteValues)
        rationum = roundedValue
        wordstyleblenderratiotext.text="目前混合比率:"+String(rationum)+"目前混合字體:"+blenderstytle
    }
    @objc func wordlengthsliderValueChanged(_ sender: UISlider) {
            // 当滑块值发生变化时，更新标签文本
        let roundedValue = Int(round(sender.value))
        wordlengthupdateValueLabel(value: roundedValue)

    }
    func wordlengthupdateValueLabel(value: Int) {
        wordlength=CGFloat(value)
        wordlengthstext.text = "目前練字框大小："+String(value)
    }
    @objc func colnumsliderValueChanged(_ sender: UISlider) {
            // 当滑块值发生变化时，更新标签文本
        let roundedValue = Int(round(sender.value))
        colnumupdateValueLabel(value: roundedValue)
    }
    func colnumupdateValueLabel(value: Int) {
        colwordnum = value
        colnumtext.text = "目前練字框數目："+String(value)
    }
    // 關閉瑩幕小鍵盤
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // 當按下右下角的return鍵時觸發
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goalString=textField.text!
        textField.resignFirstResponder() // 關閉鍵盤
        return true
    }
    @objc func openstylepicker(){
        // nowstyle／blenderstytleindex 只有工具列的「更改」（closestylepicker）
        // 才會提交。如果上次是滾一滾然後按「取消」或點空白處關掉，picker 會
        // 停在那個沒被採用的位置，下次打開看起來像已經選好了，實際上送出的
        // 還是舊風格。每次打開都先轉回真正生效中的選擇，畫面就不會騙人。
        wordstyle.selectRow(nowstyle, inComponent: 0, animated: false)
        wordstyle.selectRow(blenderstytleindex, inComponent: 1, animated: false)
        wordstytleTextField.becomeFirstResponder()
    }
    @objc func closestylepicker(){
        let stylerow = wordstyle.selectedRow(inComponent: 0)
        let blenderrow = wordstyle.selectedRow(inComponent: 1)
        nowwordstytle.text="目前字體:"+style[stylerow]
        nowstyle=stylerow
        blenderstytle=blender[blenderrow]
        blenderstytleindex=blenderrow
        wordstyleblenderratiotext.text="目前混合比率:"+String(rationum)+"目前混合字體:"+blenderstytle
        transmitstyle()
        self.view.endEditing(true)
    }
    @objc func cancelstylepicker(){
        self.view.endEditing(true)
    }
    @objc func returndata(){
        self.view.endEditing(true)
        guard !isSubmitting else { return }
        if showFormFlag{
            // 空字串送進 CalligraphyAPIClient.synthesize 會直接丟
            // APIClientError.invalidText，原本只會 print 到 console，使用者
            // 只看到「按了沒反應」。這裡先攔下來並明確告知。
            let wanted = goalString.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !wanted.isEmpty else {
                showMessage("請先輸入想練的字")
                return
            }
            setSubmitting(true)
            producewordimage(goalword: wanted)
        }
        else{
            let blend = currentBlend
            delegate.setvalue(self, wordlengt: wordlength, colnum:colwordnum,words:goalStrings,flag:showFormFlag,strokefalg: showStroke,label: nowstyle,color: currentStrokeColor,blendLabel: blend?.label2,blendRatio: blend?.ratio ?? 0)
                    dismiss(animated: true)
        }
//        print(goalwordimagebase64)
//        delegate.setvalue(self, wordlengt: wordlength, colnum: colwordnum,words:goalwordimagebase64,flag: showFormFlag)
//        dismiss(animated: true)
    }
    /// 送出期間把「確認設定」鎖起來並顯示進度，避免連點送出多個請求，
    /// 也讓使用者看得出來正在等伺服器回應（/synthesize 要跑模型推論）。
    private func setSubmitting(_ submitting: Bool) {
        isSubmitting = submitting
        confirmButton.isEnabled = !submitting
        confirmButton.configuration?.showsActivityIndicator = submitting
        confirmButton.configuration?.title = submitting ? "產生中…" : "確認設定"
    }
    private func showMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: .default))
        present(alert, animated: true)
    }
    @objc func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            showFormFlag=true
        }
        else {
            showFormFlag=false
        }
    }
    @objc func strokeChanged(_ sender: UISwitch) {
        if sender.isOn {
            showStroke=true
        }
        else {
            showStroke=false
        }
    }
    func roundValue(value: Float, discreteValues: [Float]) -> Float {
           var closestValue: Float = discreteValues[0]
           var minDifference = abs(discreteValues[0] - value)

           for discreteValue in discreteValues {
               let difference = abs(discreteValue - value)
               if difference < minDifference {
                   minDifference = difference
                   closestValue = discreteValue
               }
           }

           return closestValue
       }
    /// 舊版是把 style/blender 這個 slider 選好之後，馬上打一個獨立的 GET
    /// 請求去改伺服器端的全域狀態（"/?stytle=...&blender=..."）。新 API
    /// 是無狀態的，label 改成每次 /predict、/synthesize 請求時才用
    /// nowstyle／currentStrokeColor 帶過去（見 ViewController.swift 的
    /// saveLastStrokeAsImage() 跟這個檔案的 producewordimage()），這裡
    /// 不用再打任何網路請求，nowstyle 這個 instance var 本身已經夠用。
    ///
    /// blender（混合字體）2026-09-09 已經接上：後端 model/model.py 本來就
    /// 沒有 blender() 這個方法本體（查證過，舊版 strokeStytleChangeServer.py
    /// 呼叫的那個方法連定義都找不到），但 app/inference.py 補了
    /// predict_blend() 重建同樣的效果（兩個風格 embedding 依比率內插），
    /// 這裡的滑桿選出來的 blenderstytleindex／rationum 現在真的會送到
    /// API，見 currentBlend 這個 computed var。
    func transmitstyle(){
    }
    /// 同上，顏色現在是每次請求帶著送（見 currentStrokeColor），不用
    /// 提前用 GET 通知伺服器。
    func transmitcolor(){
    }
    /// StrokeColor 是 CalligraphyAPIClient.swift 定義的顏色參數，對應
    /// 後端 /predict/*、/synthesize/* 的 red/green/blue/alph query 參數。
    var currentStrokeColor: StrokeColor {
        StrokeColor(
            red: strokecolorInts[0],
            green: strokecolorInts[1],
            blue: strokecolorInts[2],
            alpha: strokecolorInts[3]
        )
    }
    /// blenderstytleindex 是 blender 陣列（"無" + 22 種風格）裡選到的 index，
    /// 0＝無混合。轉成 CalligraphyAPIClient.StyleBlend 給 API 用時要減 1，
    /// 因為 style 陣列（後端 label 真正對應的那份）沒有「無」這個項目。
    var currentBlend: StyleBlend? {
        guard blenderstytleindex != 0 else { return nil }
        return StyleBlend(label2: blenderstytleindex - 1, ratio: rationum)
    }
    /// 打字生成練字格：文字先用字型畫成圖，再送進模型，對應後端
    /// /synthesize/word（原本是 GET "/?goalword=..."，回傳
    /// {"data":[String]} 純 base64 陣列；新的是 POST，回傳
    /// [{char, x_position, ..., image_base64, inference_ms}] 陣列，這裡
    /// 取每個元素的 imageBase64，其餘欄位目前用不到，保留原本 [String]
    /// 傳給 ViewController.setvalue() 的介面，改動範圍降到最小）。
    func producewordimage(goalword: String) {
        let blend = currentBlend
        Task {
            do {
                let results = try await CalligraphyAPIClient.synthesize(
                    task: .word,
                    text: goalword,
                    label: nowstyle,
                    color: currentStrokeColor,
                    blend: blend
                )
                let images = results.map { $0.imageBase64 }
                await MainActor.run {
                    setSubmitting(false)
                    delegate.setvalue(
                        self, wordlengt: wordlength, colnum: colwordnum, words: images,
                        flag: showFormFlag, strokefalg: showStroke,
                        label: nowstyle, color: currentStrokeColor,
                        blendLabel: blend?.label2, blendRatio: blend?.ratio ?? 0
                    )
                    dismiss(animated: true)
                }
            } catch {
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                print("打字生成失敗：\(message)")
                // 原本失敗時只有 print，設定頁就這樣停在原地不關也不提示，
                // 使用者分不出「正在跑」還是「失敗了」。改成解鎖按鈕並明確告知。
                await MainActor.run {
                    setSubmitting(false)
                    showMessage("打字生成失敗：\(message)")
                }
            }
        }
    }
}
extension setViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
                   return style.count // 第一個分組的行數
               } else {
                   return blender.count // 第二個分組的行數
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return style[row] // 第一個分組的標題
        }
        else {
            return blender[row] // 第二個分組的標題
        }
    }
}
extension UIColor {
    func toRGBA() -> [Int] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return [] // Unable to get RGBA components
        }
        
        let intRed = Int(red * 255.0)
        let intGreen = Int(green * 255.0)
        let intBlue = Int(blue * 255.0)
        let intAlpha = Int(alpha * 255.0)
        
        return [intRed, intGreen, intBlue, intAlpha]
    }
}
