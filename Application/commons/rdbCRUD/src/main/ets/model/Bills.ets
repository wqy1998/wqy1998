import { ValuesBucket } from "@kit.ArkData"

export interface BillsValueBucket extends ValuesBucket {
  COST: number
  TYPE: number
  PAY_APP: number
  PAY_ACCOUNT: number
  CLASSIFICATION: number
  CREATE_TIME: string
  PAY_TIME: string
  YEAR: number
  MONTH: number
  DATE: number
  DAY: number
  NOTES: string
}

@Sendable
export default class Bills {
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

  private _type: number

  public set type(value: number) {
    this._type = value
  }

  public get type(): number {
    return this._type
  }

  private _payApp: number

  public set payApp(value: number) {
    this._payApp = value
  }

  public get payApp(): number {
    return this._payApp
  }

  private _payAccount: number

  public set payAccount(value: number) {
    this._payAccount = value
  }

  public get payAccount(): number {
    return this._payAccount
  }

  private _classification: number

  public set classification(value: number) {
    this._classification = value
  }

  public get classification(): number {
    return this._classification
  }

  private _createTime: string

  public set createTime(value: string) {
    this._createTime = value
  }

  public get createTime(): string {
    return this._createTime
  }

  private _payTime: string

  public set payTime(value: string) {
    this._payTime = value
  }

  public get payTime(): string {
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

  constructor(id: number, cost: number, type: number, payApp: number, payAccount: number, classification: number,
    createTime: string, payTime: string, year: number, month: number, date: number, day: number, notes: string) {
    this._id = id
    this._cost = cost
    this._type = type
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