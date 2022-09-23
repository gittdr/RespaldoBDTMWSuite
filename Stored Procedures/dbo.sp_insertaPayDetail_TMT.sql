SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




--exec d_advance_export_queue_sp
--exec sp_insertaPayDetailAnticipos 225640, 'DRV', 'MENVI', 600.00, 'CUCG'
--drop procedure sp_insertaPayDetailAnticipos
CREATE PROCEDURE [dbo].[sp_insertaPayDetail_TMT] 
(
@lgh_number int,
@asgn_type varchar(6),
@asgn_id varchar(13),
@new_advance float,
@usuario char (20),
@tmtmsg varchar(200)
)
as 

DECLARE @i_totalmsgs4            integer,
	@pyd_prorap           char(1),
	@pyt_itemcode		varchar(6),
	@orden			int,
	@mensaje		varchar(75),
	@movimiento		int,
	@pyt_rateunit   varchar(6),
	@pyt_unit		varchar(6),
	@pyt_minus		varchar(50),
	@pyt_ap_glnum	varchar (32),
	@user			varchar (255),
	@new_advance1	money,
	@new_advance2	money


execute @i_totalmsgs4 =  getsystemnumber_gateway N'PYDNUM' , NULL , 1 
--// SELECT @msg_error = (@i_totalmsgs4)

--execute @user =  gettmwuser @usuario output

select @pyd_prorap = (select mpp_actg_type from  manpowerprofile where mpp_id = @asgn_id)

select @pyt_itemcode = 'ANTOP'

--Obtener mensaje 
select @mensaje = @tmtmsg

select @pyt_rateunit = (SELECT  pyt_rateunit FROM  tmwsuite.dbo.paytype WHERE pyt_itemcode = (select gi_string2 from  generalinfo where gi_name = 'BankExportConfigSettings'))

select @pyt_unit = (SELECT  pyt_unit FROM tmwsuite.dbo.paytype WHERE pyt_itemcode = (select gi_string2 from  generalinfo where gi_name = 'BankExportConfigSettings'))

select @pyt_minus = (SELECT  pyt_pretax FROM  tmwsuite.dbo.paytype WHERE pyt_itemcode = (select gi_string2 from generalinfo where gi_name = 'BankExportConfigSettings'))

select @pyt_ap_glnum = (SELECT  pyt_ap_glnum FROM  paytype WHERE pyt_itemcode = (select gi_string2 from  generalinfo where gi_name = 'BankExportConfigSettings'))

--Obtener la orden
select @orden = (select max(ord_hdrnumber) from  tmwsuite.dbo.stops where lgh_number =@lgh_number)

--Obtener el movimiento
select @movimiento = (select mov_number from tmwsuite.dbo.legheader where lgh_number =@lgh_number )

select @new_advance1 = cast(@new_advance as money) * (-1)
select @new_advance2 = cast(@new_advance as money) * (1)

print @i_totalmsgs4
print @pyd_prorap
print @pyt_itemcode
print @mensaje
print @pyt_rateunit
print @pyt_unit
print @pyt_minus
print @pyt_ap_glnum
print 'Orden:'
print @orden
print 'movimiento:'
print @movimiento
print 'Leg'
print @lgh_number
print @new_advance1
print @new_advance2
print @usuario
print @user

INSERT INTO paydetail ( pyd_number, pyh_number, lgh_number, asgn_number, asgn_type, asgn_id, 
ivd_number, pyd_prorap, pyd_payto, pyt_itemcode, pyd_description, pyd_quantity, 
pyd_rateunit, pyd_unit, pyd_pretax, pyd_glnum, pyd_status, pyh_payperiod, 
ivd_payrevenue, mov_number, pyd_minus, pyd_workperiod, pyd_sequence, pyd_rate, 
pyd_amount, pyd_revenueratio, pyd_lessrevenue, pyd_payrevenue, pyd_loadstate, pyd_transdate, 
pyd_xrefnumber, ord_hdrnumber, pyt_fee1, pyt_fee2, pyd_grossamount, pyd_adj_flag, pyd_createdby,
pyd_maxquantity_used, pyd_maxcharge_used, pyd_vendortopay, pyd_gst_flag ) 
values(
 @i_totalmsgs4, 0, @lgh_number, 0, @asgn_type, @asgn_id, 
0, @pyd_prorap, 'UNKNOWN', @pyt_itemcode, @mensaje, 1.0000, 
@pyt_rateunit,@pyt_unit, @pyt_minus, @pyt_ap_glnum, 'HLD', {ts '2049-12-31 23:59:00.000'}, 
0.0000, @movimiento, -1, {ts '2049-12-31 23:59:00.000'}, 1, @new_advance2, 
@new_advance1, 0.0000, 0.0000, 0.0000, 'NA', current_timestamp, 
0, @orden , 0.0000, 0.0000, @new_advance1, 'N', @usuario,
'N', 'N', 'UNKNOWN', 0 )


update paydetail set pyd_createdby = @usuario where pyd_number = @i_totalmsgs4
GO
