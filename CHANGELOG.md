## 1.0.2

- Prevent infinite loop when `LruTypedDataCache` is incorrectly used with
  negative capacity.
- Allow suboptimal caches with zero capacity.
  (Changed debug assertion. In release mode zero and negative capacities
  will result in useless cache, but won't crash the app nonetheless).
- Update and add missing docs.
- Update license years.

## 1.0.1

- Explicitly return null to pass static checks.


## 1.0.0

- Initial version.
