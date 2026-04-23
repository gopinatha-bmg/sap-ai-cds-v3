@AbapCatalog.sqlViewName: 'Z_VBCHGALL'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Bank Change with Payments'
@OData.publish: true

define view Z_CDS_VBCHG_ALL
  as select from cdhdr as hdr
    inner join cdpos as pos
      on hdr.objectclas = pos.objectclas
     and hdr.objectid   = pos.objectid
     and hdr.changenr   = pos.changenr
    inner join bseg as pay
      on hdr.objectid = pay.lifnr
{
    key hdr.objectid        as Vendor,
        hdr.username        as ChangedBy,
        hdr.udate           as ChangeDate,

        pos.fname           as FieldName,
        pos.value_old       as OldValue,
        pos.value_new       as NewValue,

        pay.bukrs           as CompanyCode,
        pay.belnr           as AccountingDoc,
        pay.gjahr           as FiscalYear,
        pay.wrbtr           as PaymentAmount,
        pay.budat           as PostingDate
}
where hdr.objectclas = 'KRED'
  and pos.tabname    = 'LFBK'
  and pos.fname in ( 'BANKN', 'BANKL', 'BANKS' )
  and pay.budat >= hdr.udate
  and pay.budat <= hdr.udate + 7