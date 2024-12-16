export default class Classification {
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

  constructor(id: number, name: string) {
    this._id = id
    this._name = name
  }
}