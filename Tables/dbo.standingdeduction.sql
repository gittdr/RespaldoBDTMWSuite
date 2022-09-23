CREATE TABLE [dbo].[standingdeduction]
(
[std_number] [int] NOT NULL,
[sdm_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_balance] [money] NULL,
[std_startbalance] [money] NULL,
[std_endbalance] [money] NULL,
[std_deductionrate] [money] NULL,
[std_reductionrate] [money] NULL,
[std_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_issuedate] [datetime] NULL,
[std_closedate] [datetime] NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_priority] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[std_lastdeddate] [datetime] NULL,
[std_lastreddate] [datetime] NULL,
[std_lastcompdate] [datetime] NULL,
[std_lastcalcdate] [datetime] NULL,
[std_lastdedqty] [money] NULL,
[std_lastredqty] [money] NULL,
[std_lastcompqty] [money] NULL,
[std_lastcalcqty] [money] NULL,
[std_priordeddate] [datetime] NULL,
[std_priorreddate] [datetime] NULL,
[std_priorcompdate] [datetime] NULL,
[std_priorcalcdate] [datetime] NULL,
[std_priordedqty] [money] NULL,
[std_priorredqty] [money] NULL,
[std_priorcompqty] [money] NULL,
[std_priorcalcqty] [money] NULL,
[std_priorbalance] [money] NULL,
[std_gst] [int] NULL,
[std_refnumtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_purchase_date] [datetime] NULL,
[std_purchase_tax_state] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_RemitToVendorID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_sequential_loan] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Emilio Olvera
-- Create date:  4/20/2021
-- Description:	 Envia mensaje del standing
-- =============================================


CREATE TRIGGER [dbo].[InsertaMsgStanding] ON [dbo].[standingdeduction]
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
		@ls_parcialidades int,
		@ls_montoparcial  float



/* Se hace el select para obtener los datos que se estan insertando */
	/* y enviar el mensaje a los operadores */

SELECT 

	@ld_fechaAnt		= b.std_issuedate, 
	@ls_descripcion		= b.std_description,
	@li_montoAnt		= b.std_startbalance,
	@ls_operador		= b.asgn_id,
	@ls_paytype			= b.sdm_itemcode,
	@ls_montoparcial    = b.std_deductionrate

FROM standingdeduction a, INSERTED b
WHERE   a.std_number = b.std_number and a.std_status = 'INI' and
a.sdm_itemcode in ('DIESEL','INF','CEMS','UNIFOR')




/*
select asgn_id, mov_number, pyd_description, pyd_amount, pyd_createdon, pyt_itemcode,pyd_status, pyd_number
from paydetail where asgn_id = 'ALAIN' order by pyd_number desc
*/
-- se obtiene la unidad que esta asignada al numero de movimiento.
select @ls_unidad = mpp_tractornumber
from manpowerprofile 
where mpp_id = @ls_operador

Select @ls_unidad = RTrim(@ls_unidad)
Select @ls_unidad = LTrim(@ls_unidad)

select @ls_parcialidades =  case when @ls_montoparcial = 0 then 1 else  @li_montoAnt / @ls_montoparcial end



select * from standingdeduction

IF (1 = 1)
BEGIN

    if @ls_paytype in ('DIESEL','INF','CEMS','UNIFOR')

	begin


	  Select @ls_mensaje = 'Cargo a ' + cast(@ls_parcialidades as varchar(10)) + ' parcialidades de $'  + cast(abs(@ls_montoparcial) as varchar(20)) +  ' | '  +  isnull(cast(@ls_descripcion as varchar(255)),'') +  ' con un monto total de $ '
				 +isnull(convert(varchar(9),(abs(@li_montoAnt))),'') + 
				'. Si tienes duda o no es aplicable a ti, contactar a tu líder para aclaración, tienes una semana o el descuento se aplicará en tu siguiente liquidación.'
				
				IF  (@ls_unidad) Is not null
				Begin

				  exec tm_insertamensaje @ls_mensaje, @ls_unidad

				
			
			 
				END

	end



END
	


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iudt_standingdeduction] ON [dbo].[standingdeduction] FOR insert, update, delete  
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

INSERT INTO standingdeduction_audit (sda_number, sda_itemcode, sda_description, sda_balance, sda_startbalance, sda_endbalance, sda_deductionrate, sda_reductionrate,
                                                                                sda_status, sda_issuedate, sda_closedate, sda_asgntype, sda_asgnid, sda_priority, sda_changedate, sda_changeuser, sda_transactiontype)
SELECT std_number, sdm_itemcode, std_description, std_balance, std_startbalance, std_endbalance, std_deductionrate, std_reductionrate, 
                  std_status, std_issuedate, std_closedate, asgn_type, asgn_id, std_priority, GetDate(), User, 'I'
    FROM deleted

INSERT INTO standingdeduction_audit (sda_number, sda_itemcode, sda_description, sda_balance, sda_startbalance, sda_endbalance, sda_deductionrate, sda_reductionrate, 
                                                                                sda_status, sda_issuedate, sda_closedate, sda_asgntype, sda_asgnid, sda_priority, sda_changedate, sda_changeuser, sda_transactiontype)
SELECT std_number, sdm_itemcode, std_description, std_balance, std_startbalance, std_endbalance, std_deductionrate, std_reductionrate, 
                  std_status, std_issuedate, std_closedate, asgn_type, asgn_id, std_priority, GetDate(), User, 'D'
    FROM inserted
GO
CREATE NONCLUSTERED INDEX [dk_asgn_type_id] ON [dbo].[standingdeduction] ([asgn_type], [asgn_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_item_type_id] ON [dbo].[standingdeduction] ([sdm_itemcode], [asgn_type], [asgn_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_std_number] ON [dbo].[standingdeduction] ([std_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[standingdeduction] TO [public]
GO
GRANT INSERT ON  [dbo].[standingdeduction] TO [public]
GO
GRANT REFERENCES ON  [dbo].[standingdeduction] TO [public]
GO
GRANT SELECT ON  [dbo].[standingdeduction] TO [public]
GO
GRANT UPDATE ON  [dbo].[standingdeduction] TO [public]
GO
