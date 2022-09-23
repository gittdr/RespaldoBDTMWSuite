CREATE TABLE [dbo].[paydetail]
(
[timestamp] [binary] (8) NULL,
[pyd_number] [int] NOT NULL,
[pyh_number] [int] NULL,
[lgh_number] [int] NULL,
[asgn_number] [int] NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_number] [int] NULL,
[pyd_prorap] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[pyd_description] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyr_ratecode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_quantity] [float] NULL,
[pyd_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_rate] [money] NULL,
[pyd_amount] [money] NULL,
[pyd_pretax] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_glnum] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_currencydate] [datetime] NULL,
[pyd_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_refnumtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyh_payperiod] [datetime] NULL,
[pyd_workperiod] [datetime] NULL,
[lgh_startpoint] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_startcity] [int] NULL,
[lgh_endpoint] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_endcity] [int] NULL,
[ivd_payrevenue] [money] NULL,
[pyd_revenueratio] [float] NULL,
[pyd_lessrevenue] [money] NULL,
[pyd_payrevenue] [money] NULL,
[pyd_transdate] [datetime] NULL,
[pyd_minus] [int] NULL,
[pyd_sequence] [int] NULL,
[std_number] [int] NULL,
[pyd_loadstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_xrefnumber] [int] NULL,
[ord_hdrnumber] [int] NULL,
[pyt_fee1] [money] NULL,
[pyt_fee2] [money] NULL,
[pyd_grossamount] [money] NULL,
[pyd_adj_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_updatedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psd_id] [int] NULL,
[pyd_transferdate] [datetime] NULL,
[pyd_exportstatus] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_releasedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_billedweight] [int] NULL,
[tar_tarriffnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psd_batch_id] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_updsrc] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_updatedon] [datetime] NULL,
[pyd_offsetpay_number] [int] NULL,
[pyd_credit_pay_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_ivh_hdrnumber] [int] NULL,
[psd_number] [int] NULL,
[pyd_ref_invoice] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_ref_invoicedate] [datetime] NULL,
[pyd_ignoreglreset] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_authcode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_PostProcSource] [smallint] NULL,
[pyd_GPTrans] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cac_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccc_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_hourlypaydate] [datetime] NULL,
[pyd_isdefault] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_maxquantity_used] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_maxcharge_used] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_mbtaxableamount] [money] NULL,
[pyd_nttaxableamount] [money] NULL,
[pyd_carinvnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_carinvdate] [datetime] NULL,
[std_number_adj] [int] NULL,
[pyd_vendortopay] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_pyd_vendortopay] DEFAULT ('UNKNOWN'),
[pyd_vendorpay] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_remarks] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_number] [int] NULL,
[stp_mfh_sequence] [int] NULL,
[pyd_perdiem_exceeded] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_carrierinvoice_aprv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_carrierinvoice_rjct] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd__aprv_rjct_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_payment_date] [datetime] NULL,
[pyd_payment_doc_number] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_paid_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_paid_amount] [money] NULL,
[pyd_createdby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_createdon] [datetime] NULL,
[stp_number_pacos] [int] NULL,
[pyd_expresscode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_gst_amount] [money] NULL,
[pyd_gst_flag] [int] NULL,
[pyd_mileagetable] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_override] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_billed_reason] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_reg_time_qty] [float] NULL,
[pyt_otflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_ap_check_date] [datetime] NULL,
[pyd_ap_check_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_ap_check_amount] [decimal] (7, 2) NULL,
[pyd_ap_vendor_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_ap_updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_workcycle_status] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_workcycle_description] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_basisunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_branch_override] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_billtype_changereason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL,
[pyd_advstdnum] [int] NULL,
[pyd_min_period] [datetime] NULL,
[crd_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_ico_ivd_number_child] [int] NULL,
[pyd_ap_voucher_nbr] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_purchase_date] [datetime] NULL,
[std_purchase_tax_state] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_tax_originator_pyd_number] [int] NULL,
[pyd_thirdparty_split_percent] [float] NOT NULL CONSTRAINT [DF__paydetail__pyd_t__179BFA8D] DEFAULT ((0)),
[pyd_coowner_split_percent] [float] NULL,
[pyd_coowner_split_adj] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_report_quantity] [money] NULL,
[pyd_report_rate] [money] NULL,
[pyd_clock_start] [datetime] NULL,
[pyd_clock_end] [datetime] NULL,
[pyd_lghtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_tprsplit_number] [int] NULL,
[pyd_tprdiffbtw_number] [int] NULL,
[pyd_atd_id] [int] NULL,
[pyd_RemitToVendorID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_delays] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_reg_time_pydnum] [int] NULL,
[pyd_overlimit] [money] NULL,
[pyd_totaladvanced] [money] NULL,
[RecurringAdjustmentDetailId] [int] NULL,
[pyd_rate_factor] [float] NULL,
[pyd_fixedRate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_fixedQty] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_fixedAmount] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_parent_pyd_number] [int] NULL,
[pyd_orig_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_orig_amount] [money] NULL,
[pyd_cex_rate] [money] NULL,
[pyd_smwld_id] [int] NULL,
[pyd_pair] [int] NULL,
[termCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_reconcile] [bit] NULL,
[PayScheduleId] [int] NULL CONSTRAINT [DF__paydetail__PaySc__5E1F5334] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--  /*****************************************************/
--	Trigger que tiene como proposito insertar un paydetail a partir de una estancia.
--  

--DROP TRIGGER [InsertaAntxTalacha]

CREATE TRIGGER [dbo].[InsertaAntxTalacha] ON [dbo].[paydetail]
AFTER INSERT
AS
	DECLARE @li_lghnumber Integer,
		@li_asgn_number	Integer,
		@ls_asgn_type	varchar(8),
		@ls_asgn_id		varchar(8),
		@li_mov_number 	Integer,
		@ls_descripcion	varchar(75),
		@li_cantidad	Integer,
		@li_rate		Float,
		@li_montoAnt	Float,
		@ll_orden		Integer,
		@ld_fechaAnt	DateTime,
		@ls_createdby	varchar(8),
		@ls_operador	varchar(8),
		@ls_unidad		varchar(8),
		@ls_creadopor	varchar(8),
		@ls_adj_flag	char(1),
		@li_tienetarjeta integer


	/* Se hace el select para obtener los datos que se estan insertando */


SELECT 	@li_mov_number	= b.mov_number,
		@li_lghnumber	= b.lgh_number,
		@ll_orden		= b.ord_hdrnumber,
		@ld_fechaAnt	= b.pyd_createdon, 
		@ls_descripcion	= b.pyd_description,
		@li_montoAnt	= b.pyd_amount,
		@ls_operador	= b.asgn_id,
		@ls_creadopor	= b.pyd_createdby,
		@ls_adj_flag	= Isnull(b.pyd_adj_flag,'N')
FROM Paydetail a, INSERTED b
WHERE   a.pyd_number = b.pyd_number and a.pyd_status = 'HLD' and
a.pyt_itemcode in ('COBEST1','COMEST1','ECC1','SINIES','EM1','COMTRA','COMPRE','GR')
and Isnull(b.pyd_adj_flag,'N') = 'N'


select @ls_descripcion	= left(@ls_operador+' '+@ls_descripcion,75)
-- hace la busqueda de que el operador no tenga una tarjeta TDDE

select @li_tienetarjeta = count(*) 
from driverdocument where mpp_id = @ls_operador;

-- Operador para reconocimiento en ruta, se le dio tarjeta TDDE mala mente
if @ls_operador = 'ARAJO' 
begin
	select @li_tienetarjeta = 0;
end

IF @li_montoAnt > 0.00 and @li_tienetarjeta =0
		BEGIN
		-- Obtiene el siguiente paydetail para insertar el del anticipo...
				declare @p_controlid varchar(8)
				set @p_controlid=N'PYDNUM'
				declare @p_alternateid varchar(8)
				set @p_alternateid=null
				declare @return_detalle integer

				EXECUTE @return_detalle = dbo.getsystemnumber_gateway @p_controlid, @p_alternateid, 1
				
				INSERT INTO Paydetail
						(pyd_number,  pyh_number,		 lgh_number,  asgn_number,		 asgn_type,		 asgn_id,		 mov_number,		 pyd_description,		 pyt_itemcode,
						 pyd_quantity,				 pyd_rateunit,		 pyd_unit,		 pyd_rate,		 pyd_amount,		 pyd_pretax,		 pyd_currency,		 pyd_status, pyd_prorap,
						 pyh_payperiod,		 pyd_workperiod,		 pyd_currencydate, pyd_transdate,		 ord_hdrnumber,		 pyd_createdby	,		 pyd_minus, pyd_loadstate, pyd_grossamount )
						VALUES
						(@return_detalle, 0,		@li_lghnumber,  0,		'DRV',		@ls_operador,		@li_mov_number,			@ls_descripcion ,					'AT',
						1,		'FLT',  'FLT',		convert(money,@li_montoAnt),  convert(money,@li_montoAnt) *- 1 ,		'Y',  'MX$', 'HLD', 'A',
						'2049-12-31 23:59:00.000',		'2049-12-31 23:59:00.000',		getdate(), getdate(), @ll_orden, 'CEMSJR',	-1,  'N/A', convert(money,@li_montoAnt) *- 1	);	

						--@ls_creadopor
						UPDATE paydetail set pyd_createdby= 'CEMSJR' where pyd_number = @return_detalle;
						--UPDATE paydetail set pyd_createdby= @ls_creadopor where pyd_number = @return_detalle;
						
		
		END
GO
DISABLE TRIGGER [dbo].[InsertaAntxTalacha] ON [dbo].[paydetail]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  Trigger [dbo].[InsertaMsgAnticipo]    Script Date: 12/28/2016 12:21:43 PM ******/



--  /*****************************************************/
--	Trigger que tiene como proposito insertar un mensaje para informarle al Operador del deposito de su anticipo.
--  

--DROP TRIGGER [InsertaMsgAnticipo]

CREATE TRIGGER [dbo].[InsertaMsgAnticipo] ON [dbo].[paydetail]
AFTER INSERT
AS

	DECLARE @ls_mov_number 	Integer,
		@ll_orden		Integer,
		@ld_fechaAnt	DateTime,
		@ls_descripcion	varchar(75),
		@li_montoAnt	Float,
		@ls_operador	varchar(8),
		@ls_unidad		varchar(8),
		@ls_mensaje		Varchar(500),
		@ls_paytype		Varchar(6),
		@ls_status      varchar(6)



	/* Se hace el select para obtener los datos que se estan insertando */
	/* y enviar el mensaje a los operadores */

SELECT 	@ls_mov_number	= b.mov_number,
	@ll_orden			= b.ord_hdrnumber,
	@ld_fechaAnt		= b.pyd_createdon, 
	@ls_descripcion		= b.pyd_description,
	@li_montoAnt		= b.pyd_amount,
	@ls_operador		= b.asgn_id,
	@ls_paytype			= b.pyt_itemcode,
	@ls_status          = b.pyd_status
FROM Paydetail a, INSERTED b
WHERE   a.pyd_number = b.pyd_number and a.pyd_status  in ('HLD','PND') and
a.pyt_itemcode in ('ANTMAN','ANTOP','ECC','COBEST','COMEST','EM','DESDIE','COMTRA','CEMS','UNIFOR')



-- se obtiene la unidad que esta asignada al numero de movimiento.


-- si el movmiento es 0  trae el tracto del mapowerprofile 
if @ls_mov_number = 0
  begin
     Select @ls_unidad = (select mpp_tractornumber from manpowerprofile where mpp_id =@ls_operador)
  end
else
  begin
  select @ls_unidad = rtrim(ltrim(ord_tractor)) from orderheader  where mov_number = @ls_mov_number
  end


if @ls_status = 'PND'
 begin

     if @ls_paytype in ('DESDIE','COMTRA','CEMS','UNIFOR')
	   begin


	       Select @ls_mensaje = 'Cargo: ' +  ' por '    + isnull(cast(@ls_descripcion as varchar(255)),'') +  ' con un monto total de $ '
				 +isnull(convert(varchar(9),(abs(@li_montoAnt))),'') + 
				'. Si tienes duda o no es aplicable a ti, contactar a tu líder para aclaración, tienes una semana o el descuento se aplicará en tu siguiente liquidación.'
				
				IF  (@ls_unidad) Is not null
				Begin

				  exec tm_insertamensaje @ls_mensaje, @ls_unidad
			 
	           END

    END

END



if (@ls_status = 'HLD')
begin


	 IF @ls_paytype = 'ANTMAN' OR @ls_paytype = 'ANTOP'
		
		BEGIN
				
				Select @ls_mensaje = 'Prox. Dep. $ '
				 +isnull(convert(varchar(9),(@li_montoAnt*-1)),'')
			     + '' + isnull(cast(@ls_descripcion as varchar(255)),'') 
			     +' Mov.'+isnull(convert(varchar(6),@ls_mov_number),'') +' ' +'Orden: '+isnull(convert(varchar(6),@ll_orden),'')+
				' Hrs dep: 10:00, 13:00, 16:00 y 18:00'
				
				
				IF  (@ls_unidad) Is not null
				Begin


               exec tm_insertamensaje @ls_mensaje, @ls_unidad
			
			 
				END


		END


	ELSE
			BEGIN
			Select @ls_mensaje = 'Estancia: '+@ls_descripcion + 
					' Mov.'+convert(varchar(6),@ls_mov_number)+' ' +'Orden: '+convert(varchar(6),@ll_orden)
					
					
					IF not (@ls_unidad) Is null
					  Begin

                       exec tm_insertamensaje @ls_mensaje, @ls_unidad

  

					END
	END


END



GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itpaydetail] ON [dbo].[paydetail] 
FOR  INSERT
AS


/* Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	------------------------------------------------------
	05/17/2001	Vern Jewett		vmj1	PTS 10379: Add fingerprinting (expedite_audit table).
	02/28/2002	Vern Jewett		vmj2	PTS 12286: don't insert an audit row unless the feature is turned on.
	10/12/05	Jude Dsouza		30132	Replace convoluted subsquery with simple check for generalinfo setting
	09/20/2006	Vince Herman	34221	massage pyd_currency
	04/13/2007	Doug McRowe		36333	Check GI setting for Tracking Driver Training Deductions. If on, update the appropriat totals on the Manpowerprofiles.
	12/13/2007	Judy Swindell	38870	Added pyd_createdby and pyd_createdon
	01/10/2014	vjh				63018	Add branch
*/

Set NOCOUNT ON



--JD 52851 ************This must be the first section in the trigger, for Next Gen Back Office Applications

if exists (select * from triggerbypass where moduleid = app_name()) 
	Return

-- End JD 52581

--PTS84591 MBR 01/19/15
IF NOT EXISTS (SELECT TOP 1 * FROM inserted)
   RETURN

declare	@ls_audit	varchar(1)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--PTS 38870 JDS  12/13/07 - added createdby/createdon
UPDATE 	paydetail 
SET 	pyd_updatedby = @tmwuser ,
		pyd_updatedon = GetDate(),
		pyd_createdby = @tmwuser ,
		pyd_createdon = GetDate()   
from 	inserted
where 	inserted.pyd_number = paydetail.pyd_number

-- vjh 34221 vjh
update	paydetail
set		pyd_currency = case inserted.asgn_type
			when 'DRV' then (select isnull(mpp_currency,'UNK') from manpowerprofile where mpp_id = inserted.asgn_id)
			when 'CAR' then (select isnull(car_currency,'UNK') from carrier where car_id = inserted.asgn_id)
			when 'TRC' then (select isnull(pto_currency,'UNK') from payto where pto_id = (select trc_owner from tractorprofile where trc_number=inserted.asgn_id))
			when 'TRL' then (select isnull(pto_currency,'UNK') from payto where pto_id = (select trl_owner from trailerprofile where trl_id=inserted.asgn_id))
			when 'TPR' then (select isnull(tpr_currency,'UNK') from thirdpartyprofile where tpr_id = inserted.asgn_id)
			else 'UNK'
		end
from 	inserted
where 	inserted.pyd_number = paydetail.pyd_number
		and inserted.pyd_currency is null
-- vjh 63018 vjh
update	paydetail
set		pyd_branch = case inserted.asgn_type
			when 'DRV' then (select isnull(mpp_branch,'UNKNOWN') from manpowerprofile where mpp_id = inserted.asgn_id)
			when 'CAR' then (select isnull(car_branch,'UNKNOWN') from carrier where car_id = inserted.asgn_id)
			when 'TRC' then (select isnull(trc_branch,'UNKNOWN') from tractorprofile where trc_number=inserted.asgn_id)
			when 'TRL' then (select isnull(trl_branch,'UNKNOWN') from trailerprofile where trl_id=inserted.asgn_id)
			when 'TPR' then (select isnull(tpr_branch,'UNKNOWN') from thirdpartyprofile where tpr_id = inserted.asgn_id)
			else 'UNKNOWN'
		end
from 	inserted
where 	inserted.pyd_number = paydetail.pyd_number
		and inserted.pyd_branch is null
If exists (select * from generalinfo where gi_name = 'FingerprintAudit' and gi_string1 = 'Y') -- JD 30132 

	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(ord_hdrnumber, 0)
			,@tmwuser
			,'PayDetail inserted'
			,getdate()
			,''
			,convert(varchar(20), pyd_number)
			,isnull(mov_number, 0)
			,isnull(lgh_number, 0)
			,'paydetailaudit'
	  from	inserted

/* 
*	PTS 36333 - DJM - Track the Deduction, Forgiveness, and Bonus totals for the Driver
*/
if exists (select 1 from generalinfo where gi_name = 'DriverTrainingDeduction' and Left(gi_string1,1) = 'Y')
	Begin

		Declare @deduction_paytype varchar(8),
			@forgive_paytype	varchar(8),
			@min_pydnumber		int,
			--@forgive_amt		int,
			@line_amount		decimal(18,2),
			@bonus_paytype		varchar(8)

		Select @deduction_paytype = isNull(gi_string1,'') from generalinfo where gi_name = 'DRVTrnDeductionPayType'
		Select @forgive_paytype = isNull(gi_string1,'') from generalinfo where gi_name = 'DRVTrnForgivePayType'
		Select @bonus_paytype = isNull(gi_string1,'') from generalinfo where gi_name = 'DRVTrnBonusPayType'
	
		-- Update the Deduction totals
		select @min_pydnumber = min(pyd_number) from Inserted where pyt_itemcode = @deduction_paytype and asgn_type = 'DRV'
		while @min_pydnumber > 0
			Begin
				Update Manpowerprofile
				set mpp_cont_ded_nbr = mpp_cont_ded_nbr + 1,
					mpp_cont_remain_balance = mpp_cont_remain_balance - ABS(i.pyd_amount)
				From manpowerprofile inner join inserted i on manpowerprofile.mpp_id = i.asgn_id
				where i.pyd_number = @min_pydnumber

				select @min_pydnumber = min(pyd_number) 
				from Inserted 
				where pyt_itemcode = @deduction_paytype 
					and asgn_type = 'DRV'	
					and pyd_number > @min_pydnumber
			
			End
		
		-- Update the Forgiveness totals
		select @min_pydnumber = min(pyd_number) from Inserted where pyt_itemcode = @forgive_paytype and asgn_type = 'DRV'
		while @min_pydnumber > 0
			Begin
				select @line_amount = i.pyd_amount from inserted i where i.pyd_number = @min_pydnumber
				if ABS(@line_amount) > 0 
					Update Manpowerprofile
					set mpp_forgive_crd_nbr = mpp_forgive_crd_nbr + 1,
						mpp_forgive_remain_balance = mpp_forgive_remain_balance - ABS(i.pyd_amount)
					From manpowerprofile inner join inserted i on manpowerprofile.mpp_id = i.asgn_id
					where i.pyd_number = @min_pydnumber
				else
					Update Manpowerprofile
					set mpp_forgive_crd_nbr = mpp_forgive_crd_nbr + 1,
						mpp_forgive_remain_balance = mpp_forgive_remain_balance - ABS(mpp_forgive_week_crd_amt)
					From manpowerprofile inner join inserted i on manpowerprofile.mpp_id = i.asgn_id
					where i.pyd_number = @min_pydnumber

				select @min_pydnumber = min(pyd_number) 
				from Inserted 
				where pyt_itemcode = @forgive_paytype 
					and asgn_type = 'DRV'	
					and pyd_number > @min_pydnumber
			
			End

		-- Update the Training Bonus field
		select @min_pydnumber = min(pyd_number) from Inserted where pyt_itemcode = @bonus_paytype and asgn_type = 'DRV'
		while @min_pydnumber > 0
			Begin
				Update Manpowerprofile
				set mpp_train_anv_bonus_pd  = i.pyh_payperiod
				From manpowerprofile inner join inserted i on manpowerprofile.mpp_id = i.asgn_id
				where i.pyd_number = @min_pydnumber
					and i.pyd_status = 'PND'

				select @min_pydnumber = min(pyd_number) 
				from Inserted 
				where pyt_itemcode = @bonus_paytype 
					and asgn_type = 'DRV'	
					and pyd_number > @min_pydnumber
			
			End


	End

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  TRIGGER [dbo].[utdtpaydetail] ON [dbo].[paydetail] 
FOR  DELETE,UPDATE   
AS

-- JD Created 12/01/99
-- JD modified 12/17/99 
-- @li_audit is set for the following conditions
-- if the generalinfo gi_string1 = 'Y' or gi_string2 = 'Y'
-- gi_string1 monitors pyd_amount,gi_string2 monitors pyh_payperiod,pyd_workperiod,pyd_transferdate
-- the trigger also monitors changes of the status from XFR
-- 05/15/2001	Vern Jewett		Label=vmj1	PTS 10379: Chg audit table from PayDetailAudit to 
--											expedite_audit.
--											This script is best viewed in SQL Query Analyzer, 
--											with a tab setting of 4.
-- 02/28/2002	Vern Jewett		Label=vmj2	PTS 12286: don't insert audit row unless the feature is turned on.
-- 03/28/03 17419 - when a paydetail is deleted, also delete any associated purchaseserviceheader
--		    and purchaseservicedetail rows.
-- 07/03/03 18537 - If the login ID is a member of the db_owner group, or is 'sa', then do not check 
--                  for a row in ttsusers to determine if a delete is permitted.
-- 10/12/05	30132 	Made expedite_audit inserts unconditional, removed expedite_audit updates
-- 11/20/05	30631	Added code changes to make sure balances are adjusted appropriately
-- 09/20/2006	Vince Herman	34221	massage pyd_currency
-- LOR	PTS# 32400	update paydetailaudit with delete reason
-- PTS 36333	DJM	04/13/2007 - Check GI setting for Tracking Driver Training Deductions. If on, update the appropriate totals on the Manpowerprofiles.
-- 12/13/2007	PTS 38870	Judy Swindell	Added pyd_createdby and pyd_createdon
-- 09/14/2011	PTS 56320	vjh	Support multi-row updates
-- 04/15/2013   PTS 68712 SGB Last Update By Control 
-- 08/30/2017 PTS 106739 ERB - Fixed bug that skipped delete statements




Set NOCOUNT ON

if NOT EXISTS (select top 1 * from deleted) --106739
    return
--Per Mindy Curnutt, all triggers require this statement

--JD 52851 ************This must be the first section in the trigger, for Next Gen Back Office Applications

if exists (select * from triggerbypass where moduleid = app_name()) 
	Return

-- End JD 52581



declare	@li_audit   	int,
        @li_count   	int,
        @li_giaudit 	int, -- 1 dont skip 0 = skip audit
        @ls_status  	char(1),
        @ls_dateaudit	varchar(60),
        @ls_useraudit	varchar(60),
        @ls_pyduser 	varchar(20),
        @ls_curruser	varchar(20),
        @ldt_updated_dt	datetime,
        @ls_audit   	varchar(1),
        @li_dbowner 	int, 
        @std_number 	int, 
        @amount     	money, 
        @amount_2   	money, 
        @type       	varchar(6), 
        @id         	varchar(13),
		@reason			varchar(6)

declare @v_status varchar(6), @v_ord_status varchar(6), @v_now datetime --55570
declare @v_next int ,@v_appid varchar(30) --55570
declare @pyd_quantity float, @pyd_amount money, @ct_quantity float, @ct_amount money --55570
declare @del_pyd_quantity float, @del_pyd_amount money --55570
declare @pyh_number integer
declare @pyd_status varchar(6)
declare @ct_id int --55570
declare @Nothing int -- PTS 68712 SGB Last Update By Control


--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select @ls_status ='D'
	
select @ls_curruser = @tmwuser

select @li_count = count(*) from inserted

--vjh 34221
--vjh 56320 support multi-row updates
--if @li_count = 1
--begin
	if update(asgn_id) and not update(pyd_currency)
		update	paydetail
		set		pyd_currency = case inserted.asgn_type
			when 'DRV' then (select isnull(mpp_currency,'UNK') from manpowerprofile where mpp_id = inserted.asgn_id)
			when 'CAR' then (select isnull(car_currency,'UNK') from carrier where car_id = inserted.asgn_id)
			when 'TRC' then (select isnull(pto_currency,'UNK') from payto where pto_id = (select trc_owner from tractorprofile where trc_number=inserted.asgn_id))
			when 'TRL' then (select isnull(pto_currency,'UNK') from payto where pto_id = (select trl_owner from trailerprofile where trl_id=inserted.asgn_id))
			when 'TPR' then (select isnull(tpr_currency,'UNK') from thirdpartyprofile where tpr_id = inserted.asgn_id)
			else 'UNK'
		end
		from 	inserted
		where 	inserted.pyd_number = paydetail.pyd_number
--end

-- VV 2/21/03 PTS17304. Triggers fire even if no rows affected. Empty inserted doesn't mean that something is deleted,
-- it may mean that update trigger fired and no rows were affected. 
-- if @li_count = 0
--  PTS 18537  [begin]  PCHIC 07/03/03
/*
if EXISTS(SELECT * from deleted) and @li_count = 0
begin 
	if not exists (select * from ttsusers where usr_userid = @ls_curruser and usr_candeletepay = 'Y')
	begin
		raiserror ('User does not have delete authority. Changes made have been rolled back.',16,1)
	  rollback transaction
		return
	end
end 
*/
if EXISTS(SELECT * from deleted) and @li_count = 0
begin 
   SELECT @li_dbowner = IS_MEMBER ('db_owner') 
   if @ls_curruser = 'sa' select @li_dbowner = 1
   if @li_dbowner = 0 
   begin
      --19220 JD if not exists (select * from ttsusers where usr_userid = @ls_curruser and usr_candeletepay = 'Y')
	if exists (select * from ttsusers where usr_userid = @ls_curruser and usr_candeletepay = 'N') -- 19220 JD
	 begin
	    raiserror ('User does not have delete authority. Changes made have been rolled back.',16,1)
	    IF @@TRANCOUNT > 0  ROLLBACK TRANSACTION
	    return
         end
   end
end 
--  PTS 18537 [end]

--	select @li_giaudit = 1,@ls_dateaudit=gi_string2,@ls_useraudit=gi_string3
--	  from generalinfo where gi_name = 'AuditPay' and gi_string1 = 'Y'

-- JET - 4/8/2005 - PTS 23569, adjust standing deduction when adjustment is deleted
-- JET - 11/14/2005 - PTS 30503, make sure this code is only run on items being deleted (not updated)
select @std_number = min(std_number_adj) 
  from deleted 
where std_number_adj < 0
while @std_number < 0
begin
    select @type = asgn_type, 
           @id = asgn_id 
      from standingdeduction 
     where std_number = abs(@std_number)

    select @amount = isnull(pyd_amount, 0)
      from deleted 
     where std_number_adj = @std_number 

    select @amount_2 = isnull(pyd_amount, 0)
      from inserted 
     where std_number_adj = @std_number 
    if @amount_2 is null
      SET @amount_2 = 0
          
    if (@amount - @amount_2) <> 0
    update standingdeduction 
       set std_balance = std_balance - (@amount - @amount_2) 
     where std_number = abs(@std_number)
     
    if (@amount - @amount_2) <> 0 AND NOT EXISTS(select * from tractorprofile 
                                                  where trc_status = 'OUT' and trc_retiredate < '20491231' 
                                                    and @type = 'TRC' and @id = trc_number)
    update standingdeduction 
       set std_status = 'DRN', 
           std_closedate = '20491231 23:59:59' 
     where std_number = abs(@std_number)

   select @std_number = min(std_number_adj) 
     from deleted 
    where std_number_adj > @std_number 
      and std_number_adj < 0
end
-- JET - 4/8/2005 - PTS 23569


-- PTS 68712 SGB Last Update By Control
/*
--vjh 56320 support multi-row updates
	BEGIN 
		UPDATE 	paydetail 
		SET 	pyd_updatedby = @tmwuser ,
				pyd_updatedon = GetDate() 
		from 	inserted
		where	inserted.pyd_number = paydetail.pyd_number
	END 
	*/

If (SELECT count(1) from generalinfo where gi_name = 'PaydetailLastUpdateControl' and isnull(gi_string1,'N') = 'Y') > 0
BEGIN
	if update(pyd_ivh_hdrnumber) and not (update(pyd_amount) or update(pyh_payperiod) or update(pyd_workperiod) or 
					update(pyd_transferdate) or update(pyh_number) or update(pyd_status))
		BEGIN
		-- do nothing 68712 SGB
		select @Nothing = 1
		END
	ELSE
		BEGIN
					
		UPDATE 	paydetail 
		  SET 	pyd_updatedby = @tmwuser ,
				pyd_updatedon = GetDate() 
		  from 	inserted
		  where	inserted.pyd_number = paydetail.pyd_number
		END
END		
ELSE
	BEGIN 
		UPDATE 	paydetail 
		SET 	pyd_updatedby = @tmwuser ,
				pyd_updatedon = GetDate() 
		from 	inserted
		where	inserted.pyd_number = paydetail.pyd_number
	END 
	
-- END PTS 68712 SGB Last Update By Control



if exists(select * from generalinfo where gi_name = 'AuditPay' and upper(gi_string1) = 'Y')
	select @li_giaudit = 1

if @li_count = 1
begin
	select @ls_status='M'	
	if update(pyd_amount) or update(pyh_payperiod) or update(pyd_workperiod) or 
				update(pyd_transferdate) or update(pyh_number) or update(pyd_status)
		select @li_audit = 1

    select @ls_pyduser = pyd_updatedby from deleted
    if @ls_pyduser <> @ls_curruser
		select @li_audit = 1		

	--PTS 36955 JJF 20080626 - add provision to always audit
	IF @li_audit <> 1 or @li_audit is null BEGIN
		IF exists(SELECT * FROM generalinfo WHERE gi_name = 'AuditPay' and upper(gi_string2) = 'Y') BEGIN
			select @li_audit = 1
		END
	END
	--END PTS 36955 JJF 20080626 - add provision to always audit
end
else
	select @li_audit = 1

if @li_count > 0			--	LOR	PTS# 32400
	select @ls_status='M'	--	LOR	PTS# 32400

if @li_audit = 1 and @li_giaudit = 1 
--	LOR	PTS# 32400
Begin
	If @ls_status = 'D'
		select @reason = pdr_reason
		from paydetail_delete_reason r, deleted d
		where d.pyd_number = r.pyd_number
	Else
		select @reason = ''

	INSERT paydetailaudit(
           audit_status
           ,audit_user
           ,audit_date
           ,pyd_number
           ,pyh_number
           ,lgh_number
           ,asgn_number
           ,asgn_type
           ,asgn_id
           ,pyr_ratecode
           ,pyd_quantity
           ,pyd_rateunit
           ,pyd_unit
           ,pyd_rate
           ,pyd_amount
           ,pyd_revenueratio
           ,pyd_lessrevenue
           ,pyd_payrevenue
           ,pyt_fee1
           ,pyt_fee2
           ,pyd_grossamount
           ,pyd_status
           ,pyd_transdate
           ,pyh_payperiod
           ,pyd_workperiod
           ,pyd_transferdate
           ,pyd_currencydate
           ,pyd_updatedby
           ,pyd_updatedon
           ,pyt_itemcode
           ,std_number_adj
           ,pyd_vendortopay
           ,audit_reason_del_canc
           ,pyd_createdby
           ,pyd_createdon
           ,ivd_number
           ,pyd_prorap
           ,pyd_payto
           ,mov_number
           ,pyd_description
           ,pyd_pretax
           ,pyd_glnum
           ,pyd_currency
           ,pyd_refnumtype
           ,pyd_refnum
           ,lgh_startpoint
           ,lgh_startcity
           ,lgh_endpoint
           ,lgh_endcity
           ,ivd_payrevenue
           ,pyd_minus
           ,pyd_sequence
           ,std_number
           ,pyd_loadstate
           ,pyd_xrefnumber
           ,ord_hdrnumber
           ,pyd_adj_flag
           ,psd_id
           ,pyd_exportstatus
           ,pyd_releasedby
           ,cht_itemcode
           ,pyd_billedweight
           ,tar_tarriffnumber
           ,psd_batch_id
           ,pyd_updsrc
           ,pyd_offsetpay_number
           ,pyd_credit_pay_flag
           ,pyd_ivh_hdrnumber
           ,psd_number
           ,pyd_ref_invoice
           ,pyd_ref_invoicedate
           ,pyd_authcode
           ,pyd_PostProcSource
           ,pyd_GPTrans
           ,cac_id
           ,ccc_id
           ,pyd_hourlypaydate
           ,pyd_isdefault
           ,pyd_maxquantity_used
           ,pyd_maxcharge_used
           ,pyd_mbtaxableamount
           ,pyd_nttaxableamount
           ,pyd_carinvnum
           ,pyd_carinvdate
           ,pyd_vendorpay
           ,pyd_remarks
           ,stp_number
           ,stp_mfh_sequence
           ,pyd_perdiem_exceeded
           ,pyd_carrierinvoice_aprv
           ,pyd_carrierinvoice_rjct
           ,pyd__aprv_rjct_comment
           ,pyd_paid_indicator
           ,pyd_paid_amount
           ,pyd_payment_date
           ,pyd_payment_doc_number
           ,stp_number_pacos
           ,pyd_expresscode
           ,pyd_gst_amount
           ,pyd_gst_flag
           ,pyd_mileagetable
           ,bill_override
           ,not_billed_reason
           ,pyd_reg_time_qty
	)
	SELECT
		@ls_status,
		@tmwuser,
		getdate(),
		pyd_number,
		pyh_number ,
		lgh_number  ,
		asgn_number,
		asgn_type ,
		asgn_id,
		pyr_ratecode,
		pyd_quantity ,
		pyd_rateunit ,
		pyd_unit ,
		pyd_rate ,
		pyd_amount,
		pyd_revenueratio,
		pyd_lessrevenue ,
		pyd_payrevenue ,
		pyt_fee1 ,
		pyt_fee2 ,
		pyd_grossamount,
		pyd_status,
		pyd_transdate ,
        pyh_payperiod ,
        pyd_workperiod,
		pyd_transferdate,
		pyd_currencydate,
		pyd_updatedby,
		pyd_updatedon,
		pyt_itemcode, 
        std_number_adj,
		pyd_vendortopay,
		@reason,
		pyd_createdby,	-- PTS 38870 
		pyd_createdon,	-- PTS 38870 
       ivd_number
       ,pyd_prorap
       ,pyd_payto
       ,mov_number
       ,pyd_description
       ,pyd_pretax
       ,pyd_glnum
       ,pyd_currency
       ,pyd_refnumtype
       ,pyd_refnum
       ,lgh_startpoint
       ,lgh_startcity
       ,lgh_endpoint
       ,lgh_endcity
       ,ivd_payrevenue
       ,pyd_minus
       ,pyd_sequence
       ,std_number
       ,pyd_loadstate
       ,pyd_xrefnumber
       ,ord_hdrnumber
       ,pyd_adj_flag
       ,psd_id
       ,pyd_exportstatus
       ,pyd_releasedby
       ,cht_itemcode
       ,pyd_billedweight
       ,tar_tarriffnumber
       ,psd_batch_id
       ,pyd_updsrc
       ,pyd_offsetpay_number
       ,pyd_credit_pay_flag
       ,pyd_ivh_hdrnumber
       ,psd_number
       ,pyd_ref_invoice
       ,pyd_ref_invoicedate
       ,pyd_authcode
       ,pyd_PostProcSource
       ,pyd_GPTrans
       ,cac_id
       ,ccc_id
       ,pyd_hourlypaydate
       ,pyd_isdefault
       ,pyd_maxquantity_used
       ,pyd_maxcharge_used
       ,pyd_mbtaxableamount
       ,pyd_nttaxableamount
       ,pyd_carinvnum
       ,pyd_carinvdate
       ,pyd_vendorpay
       ,pyd_remarks
       ,stp_number
       ,stp_mfh_sequence
       ,pyd_perdiem_exceeded
       ,pyd_carrierinvoice_aprv
       ,pyd_carrierinvoice_rjct
       ,pyd__aprv_rjct_comment
       ,pyd_paid_indicator
       ,pyd_paid_amount
       ,pyd_payment_date
       ,pyd_payment_doc_number
       ,stp_number_pacos
       ,pyd_expresscode
       ,pyd_gst_amount
       ,pyd_gst_flag
       ,pyd_mileagetable
       ,bill_override
       ,not_billed_reason
       ,null --pyd_reg_time_qty

	FROM deleted
End



/* 
*	PTS 36333 - DJM - Track the Deduction and Forgiveness totals for the Driver
*/
if exists (select 1 from generalinfo where gi_name = 'DriverTrainingDeduction' and Left(gi_string1,1) = 'Y')
	Begin

		Declare @deduction_paytype varchar(8),
			@forgive_paytype	varchar(8),
			@min_pydnumber		int,
			@forgive_amt		int,
			@line_amount		decimal(18,2),
			@bonus_type			varchar(8)

		Select @deduction_paytype = isNull(gi_string1,'') from generalinfo where gi_name = 'DRVTrnDeductionPayType'
		Select @bonus_type = isNull(gi_string1,'') from generalinfo where gi_name = 'DRVTrnBonusPayType'
		Select @forgive_paytype = isNull(gi_string1,'')	from generalinfo where gi_name = 'DRVTrnForgivePayType'
	
	
		if @deduction_paytype <> ''
		Begin
			-- Update the Deduction totals
			select @min_pydnumber = min(isNull(pyd_number,0)) 
			from Deleted d
			where pyt_itemcode = @deduction_paytype 
				and asgn_type = 'DRV'
				and pyd_number > 0
				and not exists (select 1 from Inserted where d.pyd_number = Inserted.pyd_number)

			while @min_pydnumber > 0
				Begin
					Update Manpowerprofile
					set mpp_cont_ded_nbr = (mpp_cont_ded_nbr - 1),
						mpp_cont_remain_balance = (mpp_cont_remain_balance + Abs(d.pyd_amount))
					From manpowerprofile inner join deleted d on manpowerprofile.mpp_id = d.asgn_id
					where d.pyd_number = @min_pydnumber

					select @min_pydnumber = min(pyd_number) 
					from Deleted 
					where pyt_itemcode = @deduction_paytype 
						and asgn_type = 'DRV'	
						and pyd_number > @min_pydnumber
						and not exists (select 1 from Inserted where deleted.pyd_number = Inserted.pyd_number)
				
				End
		End

		if @forgive_paytype <> ''
		Begin
			-- Update the Forgiveness totals
			select @min_pydnumber = min(pyd_number) 
			from Deleted 
			where pyt_itemcode = @forgive_paytype 
				and asgn_type = 'DRV'
				and pyd_number > 0
				and not exists (select 1 from Inserted where deleted.pyd_number = Inserted.pyd_number)

			while @min_pydnumber > 0
				Begin
					select @line_amount = i.pyd_amount from inserted i where i.pyd_number = @min_pydnumber

					if ABS(@line_amount) > 0 
						Update Manpowerprofile
						set mpp_forgive_crd_nbr = mpp_forgive_crd_nbr - 1,
							mpp_forgive_remain_balance = mpp_forgive_remain_balance + ABS(d.pyd_amount)
						From manpowerprofile inner join Deleted d on manpowerprofile.mpp_id = d.asgn_id
						where d.pyd_number = @min_pydnumber
					else
						Update Manpowerprofile
						set mpp_forgive_crd_nbr = mpp_forgive_crd_nbr - 1,
							mpp_forgive_remain_balance = mpp_forgive_remain_balance + ABS(mpp_forgive_week_crd_amt)
						From manpowerprofile inner join Deleted d on manpowerprofile.mpp_id = d.asgn_id
						where d.pyd_number = @min_pydnumber


					select @min_pydnumber = min(pyd_number) 
					from Deleted 
					where pyt_itemcode = @forgive_paytype 
						and asgn_type = 'DRV'	
						and pyd_number > @min_pydnumber
						and not exists (select 1 from Inserted where deleted.pyd_number = Inserted.pyd_number)
				
				End
		end

		if @bonus_type <> ''
		Begin
			-- Update the Bonus Paid date
			select @min_pydnumber = min(isNull(pyd_number,0)) 
			from Deleted d
			where pyt_itemcode = @bonus_type 
				and asgn_type = 'DRV'
				and pyd_number > 0

			while @min_pydnumber > 0
				Begin
					if not Exists (select 1 
							from Inserted i inner join deleted d on i.pyd_number = d.pyd_number 
							where d.pyd_number = i.pyd_number )

						Update Manpowerprofile
						set	mpp_train_anv_bonus_pd = null
						From manpowerprofile inner join deleted d on manpowerprofile.mpp_id = d.asgn_id
						where d.pyd_number = @min_pydnumber
					else
						Update Manpowerprofile
						set	mpp_train_anv_bonus_pd = pyh_payperiod
						From manpowerprofile inner join inserted i on manpowerprofile.mpp_id = i.asgn_id
						where i.pyd_number = @min_pydnumber
							and i.pyd_status = 'PND'
							and i.pyd_status <> (select pyd_status from deleted where deleted.pyd_number = i.pyd_number)


					select @min_pydnumber = min(pyd_number) 
					from Deleted 
					where pyt_itemcode = @bonus_type 
						and asgn_type = 'DRV'	
						and pyd_number > @min_pydnumber
						and not exists (select 1 from Inserted where deleted.pyd_number = Inserted.pyd_number)
				
				End
		end



end

/* PTS 55570 MRH Cost tracking Insert / Modified / Delete */
If  exists (select 1 from generalinfo where UPPER(gi_name) = 'Trackrevenue' and gi_string1 = '100')
BEGIN 
	--vjh 56320 support multi-row updates
--	if (select count(*) from (select top 2 pyd_number from inserted) a ) = 1
	if (select count(*) from (select top 2 pyd_number from inserted) a ) > 0
	BEGIN --revenue tracking
		select @v_appid = rtrim(left(app_name(),30))
		select @v_now = getdate()
		select @v_next = min(pyd_number) from inserted
		while @v_next is not null
		BEGIN
			-- Back out any prior entries
			select @ct_id = max(ct_id) from cost_tracker where pyd_number = @v_next and ct_isbackout <> 'Y'
			select @pyd_quantity = pyd_quantity, @pyd_amount = pyd_amount from inserted where pyd_number = @v_next
			select @ct_quantity = ct_quantity, @ct_amount = ct_amount  from cost_tracker where ct_id = @ct_id
			if @pyd_quantity <> @ct_quantity or @pyd_amount <> @ct_amount
			begin
				Insert into cost_tracker(pyd_number, pyh_number, ord_hdrnumber, lgh_number, ct_date, pyt_itemcode, ct_amount, tar_number,
					ord_status, asgn_type, asgn_id, pyd_status, pyh_status, ct_quantity, ct_isbackout, ct_updatedby, ct_updatesource)
					select pyd_number, pyh_number, ord_hdrnumber, lgh_number, @v_now, pyt_itemcode, isnull((ct_amount * -1),0.00), tar_number,
					ord_status, asgn_type, asgn_id, pyd_status, pyh_status, isnull((ct_quantity * -1), 0), 'Y', @tmwuser, 'ut_paydetail'
					from cost_tracker where ct_id = @ct_id		
			end
			-- Add the new entries
--			select @ct_id = max(ct_id) from cost_tracker where pyd_number = @v_next and ct_isbackout <> 'Y'
--			select @pyd_quantity = pyd_quantity, @pyd_amount = pyd_amount from inserted where pyd_number = @v_next
--			select @ct_quantity = ct_quantity, @ct_amount = ct_amount  from cost_tracker where ct_id = @ct_id
			if @pyd_quantity <> @ct_quantity or @pyd_amount <> @ct_amount or @ct_id IS NULL
			begin
				select @v_status = pyh_paystatus from payheader a where a.pyh_pyhnumber = (select ins.pyh_number from inserted ins where ins.pyd_number = @v_next)
				select @v_ord_status = ord_status from orderheader o where o.ord_hdrnumber = (select ins.ord_hdrnumber from inserted ins where ins.pyd_number = @v_next)
				Insert into cost_tracker(pyd_number, pyh_number, ord_hdrnumber, lgh_number, ct_date, pyt_itemcode, ct_amount, tar_number,
					ord_status, asgn_type, asgn_id, pyd_status, pyh_status, ct_quantity, ct_isbackout, ct_updatedby, ct_updatesource)		
					select pyd_number,pyh_number,ord_hdrnumber,lgh_number,@v_now,pyt_itemcode,isnull(pyd_amount,0.00),isnull(tar_tarriffnumber, 0),
					@v_ord_status, asgn_type, asgn_id, pyd_status, @v_status, pyd_quantity, 'N', @tmwuser, 'ut_paydetail'
					from inserted ins
						where ins.pyd_number = @v_next
			end
			else -- Update payheader number and ord_status
			if @ct_id is not null
			begin
				select @pyh_number = pyh_number, @pyd_status = pyd_status from inserted where pyd_number = @v_next
				select @v_ord_status = ord_status from orderheader o where o.ord_hdrnumber = (select ins.ord_hdrnumber from inserted ins where ins.pyd_number = @v_next)
				select @v_status = pyh_paystatus from payheader a where a.pyh_pyhnumber = (select ins.pyh_number from inserted ins where ins.pyd_number = @v_next)
				update cost_tracker set pyh_number = @pyh_number, ord_status = @v_ord_status, pyh_status = @v_status where ct_id = @ct_id
			end
			select @v_next = min(pyd_number) from inserted where pyd_number > @v_next
		END
	  END
	  -- Handle Deleted records
	  --vjh 56320 support multi-row updates
--	  if (select count(*) from (select top 2 pyd_number from deleted) a ) = 1 and (select count(*) from (select top 2 pyd_number from inserted) a ) = 0
	  if (select count(*) from (select top 2 pyd_number from deleted) a ) > 0 and (select count(*) from (select top 2 pyd_number from inserted) a ) = 0
	  BEGIN
		select @v_appid = rtrim(left(app_name(),30))
		select @v_now = getdate()
		select @v_next = min(pyd_number) from deleted
		while @v_next is not null
		BEGIN
			-- Back out any prior entries
			select @ct_id = max(ct_id) from cost_tracker where pyd_number = @v_next and ct_isbackout <> 'Y'
			if isnull(@ct_id, 0) > 0
			begin
				Insert into cost_tracker(pyd_number, pyh_number, ord_hdrnumber, lgh_number, ct_date, pyt_itemcode, ct_amount, tar_number,
					ord_status, asgn_type, asgn_id, pyd_status, pyh_status, ct_quantity, ct_isbackout, ct_updatedby, ct_updatesource)
					select pyd_number, pyh_number, ord_hdrnumber, lgh_number, @v_now, pyt_itemcode, isnull((ct_amount * -1),0.00), tar_number,
					ord_status, asgn_type, asgn_id, pyd_status, pyh_status, isnull((ct_quantity * -1), 0), 'Y', @tmwuser, 'dt_paydetail'
					from cost_tracker where ct_id = @ct_id
			end
			select @v_next = min(pyd_number) from deleted where pyd_number > @v_next
		end
	end
END


/*****************************************************************************************************************************************
	 AS part of PTS 30132 All the expedite_audit updates have been removed and Inserts made unconditional
	 Always insert a row,if you get too much data thats ok, the check on the expedite_audit table forces a recompile on the trigger
	 Large customers have millions of rows in this table and checking to see if a row exists in the audit table is a costly operation
	 that holds up the update and results in recompiles and excessive locking.
*****************************************************************************************************************************************/

If not exists (select * from generalinfo where gi_name = 'FingerprintAudit' and gi_string1 = 'Y')
Return

--vmj1+	Implement the new expedite_audit mechanism.  NOTE that the Delete case immediately
--	below contains a "return", so be careful adding code to the end.
select	@ldt_updated_dt = getdate()

--Delete is a simpler case than Update..
if @li_count = 0
begin
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(ord_hdrnumber, 0)
			,@ls_curruser
			,'PayDetail deleted'
			,@ldt_updated_dt
			,''
			,convert(varchar(20), pyd_number)
			,isnull(mov_number, 0)
			,isnull(lgh_number, 0)
			,'paydetailaudit'
	  from	deleted

--  17419+
-- Delete related purchase service items
   declare @psd_number int,
	    @psh_number int
    if exists ( select * from purchaseservicedetail, deleted
        where deleted.psd_number = purchaseservicedetail.psd_number )
           begin
	      SELECT @psd_number = psd_number FROM 	deleted 
	      SELECT @psh_number = psh_number FROM 	purchaseservicedetail
	           where psd_number = @psd_number
              delete from purchaseservicedetail
		   where psd_number = @psd_number
              delete from purchaseserviceheader
		   where psh_number = @psh_number
	   end
  --17419-

--PTS 36955 JJF 20080626 - missing end statement around delete section...down below for some reason
END
--END PTS 36955 JJF 20080626 - missing end statement around delete section...down below for some reason

/*Handle Updated case.  I'm going to assume that they will never update the Primary Key, 
	pyd_number.

Amount.  Note below that -5100000000000.07 is an unlikely money value which represents NULL in 
	compares..	*/
if update(pyd_amount)

	/*
	--Update the rows that already exist..
	update	expedite_audit
	  set	update_note = ea.update_note + ', Amount ' + 
							isnull(convert(varchar(20), d.pyd_amount), 'null') + ' -> ' + 
							isnull(convert(varchar(20), i.pyd_amount), 'null')
	  from	expedite_audit ea
			,deleted d
			,inserted i
	  where	i.pyd_number = d.pyd_number
		and	isnull(i.pyd_amount, -5100000000000.07) <> isnull(d.pyd_amount, -5100000000000.07)
		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
		and	ea.updated_by = @ls_curruser
		and	ea.activity = 'PayDetail updated'
		and	ea.updated_dt = @ldt_updated_dt
		and	ea.key_value = convert(varchar(20), i.pyd_number)
		and	ea.mov_number = isnull(i.mov_number, 0)
		and	ea.lgh_number = isnull(i.lgh_number, 0)
		and	ea.join_to_table_name = 'paydetailaudit' */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_curruser
			,'PayDetail updated'
			,@ldt_updated_dt
			,'Amount ' + isnull(convert(varchar(20), d.pyd_amount), 'null') + ' -> ' + 
				isnull(convert(varchar(20), i.pyd_amount), 'null')
			,convert(varchar(20), i.pyd_number)
			,isnull(i.mov_number, 0)
			,isnull(i.lgh_number, 0)
			,'paydetailaudit'
	  from	deleted d
			,inserted i
	  where	i.pyd_number = d.pyd_number
		and	isnull(i.pyd_amount, -5100000000000.07) <> isnull(d.pyd_amount, -5100000000000.07)
/*		and	not exists
			(select	'x'
			  from	expedite_audit ea2
			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
				and	ea2.updated_by = @ls_curruser
				and	ea2.activity = 'PayDetail updated'
				and	ea2.updated_dt = @ldt_updated_dt
				and	ea2.key_value = convert(varchar(20), i.pyd_number)
				and	ea2.mov_number = isnull(i.mov_number, 0)
				and	ea2.lgh_number = isnull(i.lgh_number, 0)
				and	ea2.join_to_table_name = 'paydetailaudit') */


/* Status.  Note below that 'nU1L' is an unlikely string value which represents NULL in 
	comparisons..	*/
if update(pyd_status)

	/*
	--Update the rows that already exist..
	update	expedite_audit
	  set	update_note = ea.update_note + ', Status ' + 
							ltrim(rtrim(isnull(d.pyd_status, 'null'))) + ' -> ' + 
							ltrim(rtrim(isnull(i.pyd_status, 'null')))
	  from	expedite_audit ea
			,deleted d
			,inserted i
	  where	i.pyd_number = d.pyd_number
		and	isnull(i.pyd_status, 'nU1L') <> isnull(d.pyd_status, 'nU1L')
		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
		and	ea.updated_by = @ls_curruser
		and	ea.activity = 'PayDetail updated'
		and	ea.updated_dt = @ldt_updated_dt
		and	ea.key_value = convert(varchar(20), i.pyd_number)
		and	ea.mov_number = isnull(i.mov_number, 0)
		and	ea.lgh_number = isnull(i.lgh_number, 0)
		and	ea.join_to_table_name = 'paydetailaudit' */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_curruser
			,'PayDetail updated'
			,@ldt_updated_dt
			,'Status ' + ltrim(rtrim(isnull(d.pyd_status, 'null'))) + ' -> ' + 
				ltrim(rtrim(isnull(i.pyd_status, 'null')))
			,convert(varchar(20), i.pyd_number)
			,isnull(i.mov_number, 0)
			,isnull(i.lgh_number, 0)
			,'paydetailaudit'
	  from	deleted d
			,inserted i
	  where	i.pyd_number = d.pyd_number
		and	isnull(i.pyd_status, 'nU1L') <> isnull(d.pyd_status, 'nU1L')
/*		and	not exists
			(select	'x'
			  from	expedite_audit ea2
			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
				and	ea2.updated_by = @ls_curruser
				and	ea2.activity = 'PayDetail updated'
				and	ea2.updated_dt = @ldt_updated_dt
				and	ea2.key_value = convert(varchar(20), i.pyd_number)
				and	ea2.mov_number = isnull(i.mov_number, 0)
				and	ea2.lgh_number = isnull(i.lgh_number, 0)
				and	ea2.join_to_table_name = 'paydetailaudit') */


/* PayPeriod.  Note below that '1901-03-30' is an unlikely date value which represents NULL in 
	comparisons..	*/
if update(pyh_payperiod)

	/*
	--Update the rows that already exist..
	update	expedite_audit
	  set	update_note = ea.update_note + ', PayPeriod ' + 
							isnull(convert(varchar(30), d.pyh_payperiod, 101), 'null') + ' -> ' + 
							isnull(convert(varchar(30), i.pyh_payperiod, 101), 'null')
	  from	expedite_audit ea
			,deleted d
			,inserted i
	  where	i.pyd_number = d.pyd_number
		and	isnull(i.pyh_payperiod, '1901-03-30') <> isnull(d.pyh_payperiod, '1901-03-30')
		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
		and	ea.updated_by = @ls_curruser
		and	ea.activity = 'PayDetail updated'
		and	ea.updated_dt = @ldt_updated_dt
		and	ea.key_value = convert(varchar(20), i.pyd_number)
		and	ea.mov_number = isnull(i.mov_number, 0)
		and	ea.lgh_number = isnull(i.lgh_number, 0)
		and	ea.join_to_table_name = 'paydetailaudit' */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_curruser
			,'PayDetail updated'
			,@ldt_updated_dt
			,'PayPeriod ' + isnull(convert(varchar(30), d.pyh_payperiod, 101), 'null') + ' -> ' + 
				isnull(convert(varchar(30), i.pyh_payperiod, 101), 'null')
			,convert(varchar(20), i.pyd_number)
			,isnull(i.mov_number, 0)
			,isnull(i.lgh_number, 0)
			,'paydetailaudit'
	  from	deleted d
			,inserted i
	  where	i.pyd_number = d.pyd_number
		and	isnull(i.pyh_payperiod, '1901-03-30') <> isnull(d.pyh_payperiod, '1901-03-30')
/*		and	not exists
			(select	'x'
			  from	expedite_audit ea2
			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
				and	ea2.updated_by = @ls_curruser
				and	ea2.activity = 'PayDetail updated'
				and	ea2.updated_dt = @ldt_updated_dt
				and	ea2.key_value = convert(varchar(20), i.pyd_number)
				and	ea2.mov_number = isnull(i.mov_number, 0)
				and	ea2.lgh_number = isnull(i.lgh_number, 0)
				and	ea2.join_to_table_name = 'paydetailaudit') */


--WorkPeriod..
if update(pyd_workperiod)

	--Update the rows that already exist..
	/*
	update	expedite_audit
	  set	update_note = ea.update_note + ', WorkPeriod ' + 
							isnull(convert(varchar(30), d.pyd_workperiod, 101), 'null') + ' -> ' + 
							isnull(convert(varchar(30), i.pyd_workperiod, 101), 'null')
	  from	expedite_audit ea
			,deleted d
			,inserted i
	  where	i.pyd_number = d.pyd_number
		and	isnull(i.pyd_workperiod, '1901-03-30') <> isnull(d.pyd_workperiod, '1901-03-30')
		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
		and	ea.updated_by = @ls_curruser
		and	ea.activity = 'PayDetail updated'
		and	ea.updated_dt = @ldt_updated_dt
		and	ea.key_value = convert(varchar(20), i.pyd_number)
		and	ea.mov_number = isnull(i.mov_number, 0)
		and	ea.lgh_number = isnull(i.lgh_number, 0)
		and	ea.join_to_table_name = 'paydetailaudit' */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_curruser
			,'PayDetail updated'
			,@ldt_updated_dt
			,'WorkPeriod ' + isnull(convert(varchar(30), d.pyd_workperiod, 101), 'null') + ' -> ' + 
				isnull(convert(varchar(30), i.pyd_workperiod, 101), 'null')
			,convert(varchar(20), i.pyd_number)
			,isnull(i.mov_number, 0)
			,isnull(i.lgh_number, 0)
			,'paydetailaudit'
	  from	deleted d
			,inserted i
	  where	i.pyd_number = d.pyd_number
		and	isnull(i.pyd_workperiod, '1901-03-30') <> isnull(d.pyd_workperiod, '1901-03-30')
/*		and	not exists
			(select	'x'
			  from	expedite_audit ea2
			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
				and	ea2.updated_by = @ls_curruser
				and	ea2.activity = 'PayDetail updated'
				and	ea2.updated_dt = @ldt_updated_dt
				and	ea2.key_value = convert(varchar(20), i.pyd_number)
				and	ea2.mov_number = isnull(i.mov_number, 0)
				and	ea2.lgh_number = isnull(i.lgh_number, 0)
				and	ea2.join_to_table_name = 'paydetailaudit') */


--PayType..
if update(pyt_itemcode)
	/*
	--Update the rows that already exist..
	update	expedite_audit
	  set	update_note = ea.update_note + ', PayType ' + 
							ltrim(rtrim(isnull(d.pyt_itemcode, 'null'))) + ' -> ' + 
							ltrim(rtrim(isnull(i.pyt_itemcode, 'null')))
	  from	expedite_audit ea
			,deleted d
			,inserted i
	  where	i.pyd_number = d.pyd_number
		and	isnull(i.pyt_itemcode, 'nU1L') <> isnull(d.pyt_itemcode, 'nU1L')
		and	ea.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
		and	ea.updated_by = @ls_curruser
		and	ea.activity = 'PayDetail updated'
		and	ea.updated_dt = @ldt_updated_dt
		and	ea.key_value = convert(varchar(20), i.pyd_number)
		and	ea.mov_number = isnull(i.mov_number, 0)
		and	ea.lgh_number = isnull(i.lgh_number, 0)
		and	ea.join_to_table_name = 'paydetailaudit' */

	--Insert where the row doesn't already exist..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(i.ord_hdrnumber, 0)
			,@ls_curruser
			,'PayDetail updated'
			,@ldt_updated_dt
			,'PayType ' + ltrim(rtrim(isnull(d.pyt_itemcode, 'null'))) + ' -> ' + 
				ltrim(rtrim(isnull(i.pyt_itemcode, 'null')))
			,convert(varchar(20), i.pyd_number)
			,isnull(i.mov_number, 0)
			,isnull(i.lgh_number, 0)
			,'paydetailaudit'
	  from	deleted d
			,inserted i
	  where	i.pyd_number = d.pyd_number
		and	isnull(i.pyt_itemcode, 'nU1L') <> isnull(d.pyt_itemcode, 'nU1L')
/*		and	not exists
			(select	'x'
			  from	expedite_audit ea2
			  where	ea2.ord_hdrnumber = isnull(i.ord_hdrnumber, 0)
				and	ea2.updated_by = @ls_curruser
				and	ea2.activity = 'PayDetail updated'
				and	ea2.updated_dt = @ldt_updated_dt
				and	ea2.key_value = convert(varchar(20), i.pyd_number)
				and	ea2.mov_number = isnull(i.mov_number, 0)
				and	ea2.lgh_number = isnull(i.lgh_number, 0)
				and	ea2.join_to_table_name = 'paydetailaudit')*/

--vmj1-
--PTS 36955 JJF 20080626 - missing end statement around delete section...down below for some reason
--end
--END PTS 36955 JJF 20080626 - missing end statement around delete section...down below for some reason

GO
CREATE NONCLUSTERED INDEX [ix_pyd_asgn_id_type_num_stat] ON [dbo].[paydetail] ([asgn_id], [asgn_type], [pyd_number], [pyd_status], [pyh_payperiod], [pyd_transdate], [pyd_workperiod], [pyt_itemcode], [ord_hdrnumber], [psd_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_asgnnum] ON [dbo].[paydetail] ([asgn_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pyd_type_id_lghnum] ON [dbo].[paydetail] ([asgn_type], [asgn_id], [lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ck_type_id] ON [dbo].[paydetail] ([asgn_type], [asgn_id], [pyh_payperiod]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_pd_type_mov_lgh_id_amt] ON [dbo].[paydetail] ([asgn_type], [mov_number], [lgh_number], [asgn_id], [pyd_amount]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Paydetail_timestamp] ON [dbo].[paydetail] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_paydetail_ivd_number] ON [dbo].[paydetail] ([ivd_number]) INCLUDE ([pyd_branch], [pyd_branch_override]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lghnum] ON [dbo].[paydetail] ([lgh_number], [pyh_number], [pyd_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_mov_number] ON [dbo].[paydetail] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ordhdrnumber] ON [dbo].[paydetail] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_paydetail_pyd_atd_id] ON [dbo].[paydetail] ([pyd_atd_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_pyd_carinvnum] ON [dbo].[paydetail] ([pyd_carinvnum]) INCLUDE ([ord_hdrnumber]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pyd_ivh_hdrnumber] ON [dbo].[paydetail] ([pyd_ivh_hdrnumber]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_pyd_number] ON [dbo].[paydetail] ([pyd_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_pyd_refnum_refnumtype_lghnum] ON [dbo].[paydetail] ([pyd_refnum], [pyd_refnumtype], [lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [paydetail_refnums] ON [dbo].[paydetail] ([pyd_refnumtype], [pyd_refnum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_paydetail_pyd_smwld_id] ON [dbo].[paydetail] ([pyd_smwld_id]) INCLUDE ([pyd_amount]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pyd_status] ON [dbo].[paydetail] ([pyd_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pyd_transdate] ON [dbo].[paydetail] ([pyd_transdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_paydetail_pyd_updatedon] ON [dbo].[paydetail] ([pyd_updatedon]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_pyh_pyd] ON [dbo].[paydetail] ([pyh_number], [pyd_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_pyd_collect_paydetails] ON [dbo].[paydetail] ([pyh_number], [pyd_pretax], [pyd_status], [pyd_amount], [pyd_minus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_pd_payperiod_status_pretax_minus] ON [dbo].[paydetail] ([pyh_payperiod], [pyd_status], [pyd_pretax], [pyd_minus]) INCLUDE ([asgn_type], [asgn_id], [pyd_amount]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_itemcodeworkper] ON [dbo].[paydetail] ([pyt_itemcode], [pyd_workperiod]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paydetail] ADD CONSTRAINT [fk_paydetail_pyd_atd_id] FOREIGN KEY ([pyd_atd_id]) REFERENCES [dbo].[assetassignment_tour_dtl] ([atd_id]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[paydetail] ADD CONSTRAINT [fk_paydetail_pyd_smwld_id] FOREIGN KEY ([pyd_smwld_id]) REFERENCES [dbo].[stateminimumwagelog_dtl] ([smwld_id]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[paydetail] ADD CONSTRAINT [FK_paydetail_RecurringAdjustmentDetail] FOREIGN KEY ([RecurringAdjustmentDetailId]) REFERENCES [dbo].[RecurringAdjustmentDetail] ([RecurringAdjustmentDetailId])
GO
GRANT DELETE ON  [dbo].[paydetail] TO [public]
GO
GRANT INSERT ON  [dbo].[paydetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paydetail] TO [public]
GO
GRANT SELECT ON  [dbo].[paydetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[paydetail] TO [public]
GO
