@EndUserText.label: 'Vendor Bank Change with Payments'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@OData.publish: true

define view entity Z_CDS_VBCHG_ALL
  as select from cdhdr as hdr

    inner join cdpos as pos
      on hdr.objectclas = pos.objectclas
     and hdr.objectid   = pos.objectid
     and hdr.changenr   = pos.changenr

    inner join I_JournalEntryItem as je
      on je.Supplier = hdr.objectid

{
      key hdr.objectid            as Vendor,
      key hdr.changenr           as ChangeNumber,
      key je.CompanyCode         as CompanyCode,
      key je.AccountingDocument  as AccountingDocument,
      key je.FiscalYear          as FiscalYear,
      key je.LedgerGLLineItem    as LineItem,

          hdr.username           as ChangedBy,
          hdr.udate              as ChangeDate,
          hdr.utime              as ChangeTime,

          pos.tabname            as TableName,
          pos.fname              as FieldName,
          pos.value_old          as OldValue,
          pos.value_new          as NewValue,

          je.PostingDate         as PostingDate,

          @Semantics.amount.currencyCode: 'Currency'
          je.AmountInCompanyCodeCurrency as Amount,

          je.CompanyCodeCurrency as Currency,

          je.DocumentItemText    as ItemText
}
where hdr.objectclas = 'KRED'
  and pos.tabname    = 'LFBK'
  and (
       pos.fname = 'BANKN'
    or pos.fname = 'BANKL'
    or pos.fname = 'BANKS'
      )
  and je.PostingDate >= hdr.udate