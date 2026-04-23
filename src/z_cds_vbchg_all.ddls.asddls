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

    inner join bseg as pay
      on pay.lifnr = hdr.objectid

    inner join bkpf as doc
      on doc.bukrs = pay.bukrs
     and doc.belnr = pay.belnr
     and doc.gjahr = pay.gjahr

{
      key hdr.objectid   as Vendor,
      key hdr.changenr   as ChangeNumber,
      key pay.bukrs      as CompanyCode,
      key pay.belnr      as AccountingDocument,
      key pay.gjahr      as FiscalYear,

          hdr.username   as ChangedBy,
          hdr.udate      as ChangeDate,
          hdr.utime      as ChangeTime,

          pos.tabname    as TableName,
          pos.fname      as FieldName,
          pos.value_old  as OldValue,
          pos.value_new  as NewValue,

          doc.budat      as PostingDate,
          pay.wrbtr      as PaymentAmount,
          pay.shkzg      as DebitCreditInd
}
where hdr.objectclas = 'KRED'
  and pos.tabname    = 'LFBK'
  and (
       pos.fname = 'BANKN'
    or pos.fname = 'BANKL'
    or pos.fname = 'BANKS'
      )
  and doc.budat >= hdr.udate
  and doc.budat <= add_days( hdr.udate, 7 )