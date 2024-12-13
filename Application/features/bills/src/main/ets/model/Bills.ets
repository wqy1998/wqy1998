export default class Bills{
  private _id: number

  public get id(): number {
    return this._id
  }
  private _cost: number

  public set cost(value: number) {
    this._cost = value
  }

  public get cost(): number {
    return this._cost
  }

  private _payApp: string

  public set payApp(value: string) {
    this._payApp = value
  }

  public get payApp(): string {
    return this._payApp
  }

  private _payAccount: string

  public set payAccount(value: string) {
    this._payAccount = value
  }

  public get payAccount(): string {
    return this._payAccount
  }

  private _classification: string

  public set classification(value: string) {
    this._classification = value
  }

  public get classification(): string {
    return this._classification
  }

  private _createTime: Date

  public set createTime(value: Date) {
    this._createTime = value
  }

  public get createTime(): Date {
    return this._createTime
  }

  private _payTime: Date

  public set payTime(value: Date) {
    this._payTime = value
  }

  public get payTime(): Date {
    return this._payTime
  }

  private _year: number

  public set year(value: number) {
    this._year = value
  }

  public get year(): number {
    return this._year
  }

  private _month: number

  public set month(value: number) {
    this._month = value
  }

  public get month(): number {
    return this._month
  }

  private _date: number

  public set date(value: number) {
    this._date = value
  }

  public get date(): number {
    return this._date
  }

  private _day: number

  public set day(value: number) {
    this._day = value
  }

  public get day(): number {
    return this._day
  }

  private _notes: string

  public set notes(value: string) {
    this._notes = value
  }

  public get notes(): string {
    return this._notes
  }

  constructor(id: number, cost: number, payApp: string, payAccount: string, classification: string, createTime: Date,
    payTime: Date, year: number, month: number, date: number, day: number, notes: string) {
    this._id = id
    this._cost = cost
    this._payApp = payApp
    this._payAccount = payAccount
    this._classification = classification
    this._createTime = createTime
    this._payTime = payTime
    this._year = year
    this._month = month
    this._date = date
    this._day = day
    this._notes = notes
  }
}