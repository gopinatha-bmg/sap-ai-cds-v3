@EndUserText.label: 'Duplicate Invoice Check'
@OData.publish: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #CONSUMPTION

define view entity Z_CDS_VBCHG_ALL
as select from I_SupplierInvoice as inv1

-- Self-join on five duplicate criteria:
-- same invoicing party (vendor), same external reference number,
-- same gross amount, same currency, same company code
-- but different SAP document numbers.
-- The < condition ensures each duplicate pair appears exactly once.
inner join I_SupplierInvoice as inv2
on inv1.InvoicingParty = inv2.InvoicingParty
and inv1.SupplierInvoiceIDByInvcgParty = inv2.SupplierInvoiceIDByInvcgParty
and inv1.InvoiceGrossAmount = inv2.InvoiceGrossAmount
and inv1.DocumentCurrency = inv2.DocumentCurrency
and inv1.CompanyCode = inv2.CompanyCode
and inv1.SupplierInvoice < inv2.SupplierInvoice

{
key inv1.SupplierInvoice as OriginalInvoiceDoc,
key inv2.SupplierInvoice as DuplicateInvoiceDoc,
key inv1.FiscalYear as FiscalYear,
key inv1.CompanyCode as CompanyCode,

inv1.InvoicingParty as Vendor,

-- Vendor's own invoice reference — primary duplicate signal
inv1.SupplierInvoiceIDByInvcgParty as ExternalInvoiceNumber,

inv1.DocumentDate as OriginalDocumentDate,
inv2.DocumentDate as DuplicateDocumentDate,

inv1.PostingDate as OriginalPostingDate,
inv2.PostingDate as DuplicatePostingDate,

@Semantics.amount.currencyCode: 'Currency'
inv1.InvoiceGrossAmount as Amount,

inv1.DocumentCurrency as Currency,

-- ReverseDocument: blank = active, filled = this doc was reversed by another
inv1.ReverseDocument as OriginalReversedBy,
inv2.ReverseDocument as DuplicateReversedBy,

inv1.SupplierInvoiceStatus as OriginalStatus,
inv2.SupplierInvoiceStatus as DuplicateStatus,

inv1.CreatedByUser as OriginalCreatedBy,
inv2.CreatedByUser as DuplicateCreatedBy,

inv1.CreationDate as OriginalCreationDate,
inv2.CreationDate as DuplicateCreationDate,

inv1.DocumentHeaderText as OriginalHeaderText,
inv2.DocumentHeaderText as DuplicateHeaderText
}
where
-- Scope to last 30 days based on original invoice posting date
inv1.PostingDate >= dats_add_days( $session.system_date, -30, 'FAIL' )
and inv1.PostingDate <= $session.system_date

-- Exclude pairs where BOTH documents are already reversed.
-- If only one is reversed the pair still appears — the active one needs review.
and not ( inv1.ReverseDocument <> '' and inv2.ReverseDocument <> '' )