export default interface PaginationResult<T> {
  results?: T[] | null;
  /** Format: int32 */
  pageIndex?: number;
  /** Format: int32 */
  pageSize?: number;
  /** Format: int32 */
  pageCount?: number;
  /** Format: int32 */
  totalCount?: number;
}
