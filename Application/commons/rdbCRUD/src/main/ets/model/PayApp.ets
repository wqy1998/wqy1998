@Sendable
export default class PayApp {
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

  private _createTime: string

  public set createTime(value: string) {
    this._createTime = value
  }

  public get createTime(): string {
    return this._createTime
  }

  constructor(id: number, name: string, createTime: string) {
    this._id = id
    this._name = name
    this._createTime = createTime
  }
}