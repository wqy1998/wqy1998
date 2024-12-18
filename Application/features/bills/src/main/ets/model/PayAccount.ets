export default class PayAccount {
  private _id: number

  public get id(): number {
    return this._id
  }

  private _name: string

  public set name(value: string) {
    this._name = value
  }

  public get name(): string {
    return this._name
  }

  private _amount: number

  public set amount(value: number) {
    this._amount = value
  }

  public get amount(): number {
    return this._amount
  }

  private _createTime: string

  public set createTime(value: string) {
    this._createTime = value
  }

  public get createTime(): string {
    return this._createTime
  }

  constructor(id: number, name: string, amount: number, createTime: string) {
    this._id = id
    this._name = name
    this._amount = amount
    this._createTime = createTime
  }
}