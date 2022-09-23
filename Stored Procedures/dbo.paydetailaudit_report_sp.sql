SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[paydetailaudit_report_sp] (@pl_lghnum int) as

/* Revision History:
LOR	PTS# 32400	add delete reason
*/
declare @pyd_number int

create table #temp(audit_sequence int null ,
	audit_status char (1)  NULL ,
	audit_user varchar (20)  NULL ,
	audit_date datetime NULL ,
	pyd_number int NULL ,
	pyh_number int NULL ,
	lgh_number int NULL ,
	asgn_number int NULL ,
	asgn_type varchar (6) NULL ,
	asgn_id varchar (8) NULL ,
	pyr_ratecode varchar (6) NULL ,
	pyd_quantity float NULL ,
	pyd_rateunit varchar (6) NULL ,
	pyd_unit varchar (6) NULL ,
	pyd_rate money NULL ,
	pyd_amount money NULL ,
	pyd_revenueratio float NULL ,
	pyd_lessrevenue money NULL ,
	pyd_payrevenue money NULL ,
	pyt_fee1 money NULL ,
	pyt_fee2 money NULL ,
	pyd_grossamount money NULL ,
	pyd_status varchar (6) NULL,
	pyt_itemcode varchar(6) NULL,
	del_reason varchar(6) null)

	create table #paydetails (pyd_number int not null)
	
	insert into #paydetails 
	select pyd_number from paydetail where lgh_number = @pl_lghnum
	union
	select distinct pyd_number from paydetailaudit where lgh_number = @pl_lghnum

	select @pyd_number = 0
	while 1 = 1 
	begin
	    select @pyd_number = min(pyd_number) from #paydetails where pyd_number > @pyd_number		
	    if @pyd_number is null
		break

	    if not exists (select * from paydetailaudit where pyd_number = @pyd_number)
	     begin	
		Insert into #temp
 		 (audit_sequence,   
	         audit_status,   
        	 audit_user,   
	         audit_date,   
        	 pyd_number,   
	         pyh_number,   
        	 lgh_number,   
	         asgn_number,   
        	 asgn_type,   
	         asgn_id,   
        	 pyr_ratecode,   
	         pyd_quantity,   
        	 pyd_rateunit,   
	         pyd_unit,   
        	 pyd_rate,   
	         pyd_amount,   
        	 pyd_revenueratio,   
	         pyd_lessrevenue,   
        	 pyd_payrevenue,   
	         pyt_fee1,   
        	 pyt_fee2,   
	         pyd_grossamount,   
        	 pyd_status,
		 pyt_itemcode,
			del_reason)
		 (select	
		 0,   
	         'X',   	
        	 pyd_updatedby,   
	         pyd_updatedon,   
        	 pyd_number,   
	         pyh_number,   
        	 lgh_number,   
	         asgn_number,   
        	 asgn_type,   
	         asgn_id,   
        	 pyr_ratecode,   
	         pyd_quantity,   
        	 pyd_rateunit,   
	         pyd_unit,   
        	 pyd_rate,   
	         pyd_amount,   
        	 pyd_revenueratio,   
	         pyd_lessrevenue,   
        	 pyd_payrevenue,   
	         pyt_fee1,   
        	 pyt_fee2,   
	         pyd_grossamount,   
        	 pyd_status,
		 pyt_itemcode,
			'      ' del_reason
		from paydetail
		where pyd_number = @pyd_number)
		
	     end
	    else		 
	     begin	
	     if exists (select * from paydetailaudit where pyd_number=@pyd_number and audit_status ='D')
	       begin
		Insert into #temp
 		 (audit_sequence,   
	         audit_status,   
        	 audit_user,   
	         audit_date,   
        	 pyd_number,   
	         pyh_number,   
	         lgh_number,   
        	 asgn_number,   
	         asgn_type,   
		 asgn_id,   
	         pyr_ratecode,   
        	 pyd_quantity,   
	         pyd_rateunit,   
        	 pyd_unit,   
	         pyd_rate,   
        	 pyd_amount,   
	         pyd_revenueratio,   
        	 pyd_lessrevenue,   
	         pyd_payrevenue,   
        	 pyt_fee1,   
	         pyt_fee2,   
        	 pyd_grossamount,   
	         pyd_status,
		 pyt_itemcode,
			del_reason)
		 (select	
		 0,   
        	 'X',   
	         pyd_updatedby,   
        	 pyd_updatedon,   
	         pyd_number,   
        	 pyh_number,   
	         lgh_number,   
        	 asgn_number,   
	         asgn_type,   
        	 asgn_id,   
	         pyr_ratecode,   
        	 pyd_quantity,   
	         pyd_rateunit,   
        	 pyd_unit,   
	         pyd_rate,   
        	 pyd_amount,   
	         pyd_revenueratio,   
        	 pyd_lessrevenue,   
	         pyd_payrevenue,   
        	 pyt_fee1,   
	         pyt_fee2,   
        	 pyd_grossamount,   
	         pyd_status,
		 pyt_itemcode,
			audit_reason_del_canc del_reason
		from  paydetailaudit
		where pyd_number = @pyd_number and
	       		audit_sequence = (select min(b.audit_sequence) from paydetailaudit b 
								where   b.pyd_number = paydetailaudit.pyd_number ))


		Insert into #temp
 		 (audit_sequence,   
	         audit_status,   
        	 audit_user,   
	         audit_date,   
        	 pyd_number,   
	         pyh_number,   
	         lgh_number,   
        	 asgn_number,   
	         asgn_type,   
		 asgn_id,   
	         pyr_ratecode,   
        	 pyd_quantity,   
	         pyd_rateunit,   
        	 pyd_unit,   
	         pyd_rate,   
        	 pyd_amount,   
	         pyd_revenueratio,   
        	 pyd_lessrevenue,   
	         pyd_payrevenue,   
        	 pyt_fee1,   
	         pyt_fee2,   
        	 pyd_grossamount,   
	         pyd_status,
		 pyt_itemcode,
			del_reason)
		 (select	
		 a.audit_sequence,   
        	 a.audit_status,   
	         a.audit_user,   
        	 a.audit_date,   
	         a.pyd_number,   
        	 a.pyh_number,   
	         a.lgh_number,   
        	 a.asgn_number,   
	         a.asgn_type,   
        	 a.asgn_id,   
	         b.pyr_ratecode,   
        	 b.pyd_quantity,   
	         b.pyd_rateunit,   
        	 b.pyd_unit,   
	         b.pyd_rate,   
        	 b.pyd_amount,   
	         b.pyd_revenueratio,   
        	 b.pyd_lessrevenue,   
	         b.pyd_payrevenue,   
        	 b.pyt_fee1,   
	         b.pyt_fee2,   
        	 b.pyd_grossamount,   
	         b.pyd_status,
		 b.pyt_itemcode	,
			a.audit_reason_del_canc del_reason
		from  paydetailaudit a,paydetailaudit b
		where a.pyd_number = @pyd_number and
		      a.pyd_number = b.pyd_number and
		      b.audit_sequence =(select min(c.audit_sequence) from 
		      paydetailaudit c where c.pyd_number = @pyd_number and c.audit_sequence > a.audit_sequence))

		Insert into #temp
 		 (audit_sequence,   
	         audit_status,   
        	 audit_user,   
	         audit_date,   
        	 pyd_number,   
	         pyh_number,   
	         lgh_number,   
        	 asgn_number,   
	         asgn_type,   
		 asgn_id,   
	         pyr_ratecode,   
        	 pyd_quantity,   
	         pyd_rateunit,   
        	 pyd_unit,   
	         pyd_rate,   
        	 pyd_amount,   
	         pyd_revenueratio,   
        	 pyd_lessrevenue,   
	         pyd_payrevenue,   
        	 pyt_fee1,   
	         pyt_fee2,   
        	 pyd_grossamount,   
	         pyd_status,
		 pyt_itemcode,
			del_reason)
		 (select	
		 audit_sequence,   
        	 audit_status,   
	         audit_user,   
        	 audit_date,   
	         pyd_number,   
        	 pyh_number,   
	         lgh_number,   
        	 asgn_number,   
	         asgn_type,   
        	 asgn_id,   
	         pyr_ratecode,   
        	 pyd_quantity,   
	         pyd_rateunit,   
        	 pyd_unit,   
	         pyd_rate,   
        	 pyd_amount,   
	         pyd_revenueratio,   
        	 pyd_lessrevenue,   
	         pyd_payrevenue,   
        	 pyt_fee1,   
	         pyt_fee2,   
        	 pyd_grossamount,   
	         pyd_status,
		 pyt_itemcode,
			audit_reason_del_canc del_reason
		from  paydetailaudit
		where pyd_number = @pyd_number and audit_status = 'D')

       end
	     else
	       begin
		Insert into #temp
 		 (audit_sequence,   
	         audit_status,   
        	 audit_user,   
	         audit_date,   
        	 pyd_number,   
	         pyh_number,   
	         lgh_number,   
        	 asgn_number,   
	         asgn_type,   
		 asgn_id,   
	         pyr_ratecode,   
        	 pyd_quantity,   
	         pyd_rateunit,   
        	 pyd_unit,   
	         pyd_rate,   
        	 pyd_amount,   
	         pyd_revenueratio,   
        	 pyd_lessrevenue,   
	         pyd_payrevenue,   
        	 pyt_fee1,   
	         pyt_fee2,   
        	 pyd_grossamount,   
	         pyd_status,
		 pyt_itemcode,
			del_reason)
		 (select	
		 0,   
        	 'X',   
	         paydetailaudit.pyd_updatedby,   
        	 paydetailaudit.pyd_updatedon,   
	         paydetailaudit.pyd_number,   
        	 paydetailaudit.pyh_number,   
	         paydetailaudit.lgh_number,   
        	 paydetailaudit.asgn_number,   
	         paydetailaudit.asgn_type,   
        	 paydetailaudit.asgn_id,   
	         paydetailaudit.pyr_ratecode,   
        	 paydetailaudit.pyd_quantity,   
	         paydetailaudit.pyd_rateunit,   
        	 paydetailaudit.pyd_unit,   
	         paydetailaudit.pyd_rate,   
        	 paydetailaudit.pyd_amount,   
	         paydetailaudit.pyd_revenueratio,   
        	 paydetailaudit.pyd_lessrevenue,   
	         paydetailaudit.pyd_payrevenue,   
        	 paydetailaudit.pyt_fee1,   
	         paydetailaudit.pyt_fee2,   
        	 paydetailaudit.pyd_grossamount,   
	         paydetailaudit.pyd_status,
		 paydetailaudit.pyt_itemcode,
			audit_reason_del_canc del_reason	
		from  paydetailaudit,paydetail
		where paydetail.pyd_number = @pyd_number and
		       paydetailaudit.pyd_number = paydetail.pyd_number and	
	       		paydetailaudit.audit_sequence = (select min(b.audit_sequence) from paydetailaudit b 
								where   b.pyd_number = paydetailaudit.pyd_number and 
									b.audit_status = 'M'))

		-- all modified > min
		Insert into #temp
 		 (audit_sequence,   
	         audit_status,   
        	 audit_user,   
	         audit_date,   
        	 pyd_number,   
	         pyh_number,   
	         lgh_number,   
        	 asgn_number,   
	         asgn_type,   
		 asgn_id,   
	         pyr_ratecode,   
        	 pyd_quantity,   
	         pyd_rateunit,   
        	 pyd_unit,   
	         pyd_rate,   
        	 pyd_amount,   
	         pyd_revenueratio,   
        	 pyd_lessrevenue,   
	         pyd_payrevenue,   
        	 pyt_fee1,   
	         pyt_fee2,   
        	 pyd_grossamount,   
	         pyd_status,
		 pyt_itemcode,
			del_reason)
		 (select	
		 a.audit_sequence,   
        	 a.audit_status,   
	         a.audit_user,   
        	 a.audit_date,   
	         a.pyd_number,   
        	 a.pyh_number,   
	         a.lgh_number,   
        	 a.asgn_number,   
	         a.asgn_type,   
        	 a.asgn_id,   
	         b.pyr_ratecode,   
        	 b.pyd_quantity,   
	         b.pyd_rateunit,   
        	 b.pyd_unit,   
	         b.pyd_rate,   
        	 b.pyd_amount,   
	         b.pyd_revenueratio,   
        	 b.pyd_lessrevenue,   
	         b.pyd_payrevenue,   
        	 b.pyt_fee1,   
	         b.pyt_fee2,   
        	 b.pyd_grossamount,   
	         b.pyd_status,
		 b.pyt_itemcode	,
			a.audit_reason_del_canc del_reason
		from  paydetailaudit a,paydetailaudit b
		where a.pyd_number = @pyd_number and
		      a.pyd_number = b.pyd_number and
		      b.audit_sequence =(select min(c.audit_sequence) from 
		      paydetailaudit c where c.pyd_number = @pyd_number and c.audit_sequence > a.audit_sequence))
/*		from  paydetailaudit
		where paydetailaudit.pyd_number = @pyd_number and
		      paydetailaudit.audit_sequence > (select min(b.audit_sequence) from paydetailaudit b 
								where   b.pyd_number = @pyd_number and 
									b.audit_status = 'M'))*/

		Insert into #temp
 		 (audit_sequence,   
	         audit_status,   
        	 audit_user,   
	         audit_date,   
        	 pyd_number,   
	         pyh_number,   
	         lgh_number,   
        	 asgn_number,   
	         asgn_type,   
		 asgn_id,   
	         pyr_ratecode,   
        	 pyd_quantity,   
	         pyd_rateunit,   
        	 pyd_unit,   
	         pyd_rate,   
        	 pyd_amount,   
	         pyd_revenueratio,   
        	 pyd_lessrevenue,   
	         pyd_payrevenue,   
        	 pyt_fee1,   
	         pyt_fee2,   
        	 pyd_grossamount,   
	         pyd_status,
		 pyt_itemcode,
			del_reason)
		 (select	
		 9999999,   
        	 'M',   
	         paydetail.pyd_updatedby,   
        	 paydetail.pyd_updatedon,   
	         paydetail.pyd_number,   
        	 paydetail.pyh_number,   
	         paydetail.lgh_number,   
        	 paydetail.asgn_number,   
	         paydetail.asgn_type,   
        	 paydetail.asgn_id,   
	         paydetail.pyr_ratecode,   
        	 paydetail.pyd_quantity,   
	         paydetail.pyd_rateunit,   
        	 paydetail.pyd_unit,   
	         paydetail.pyd_rate,   
        	 paydetail.pyd_amount,   
	         paydetail.pyd_revenueratio,   
        	 paydetail.pyd_lessrevenue,   
	         paydetail.pyd_payrevenue,   
        	 paydetail.pyt_fee1,   
	         paydetail.pyt_fee2,   
        	 paydetail.pyd_grossamount,   
	         paydetail.pyd_status,
		 paydetail.pyt_itemcode	,
			'      ' del_reason		
		from  paydetail
		where paydetail.pyd_number = @pyd_number )

	       end		
	  end		
		    	
	end

select 
	audit_sequence,   
	audit_status,   
    audit_user,   
	audit_date,   
    pyd_number,   
	pyh_number,   
	lgh_number,   
    asgn_number,   
	asgn_type,   
	asgn_id,   
	pyr_ratecode,   
    pyd_quantity,   
	pyd_rateunit,   
    pyd_unit,   
	pyd_rate,   
    pyd_amount,   
	pyd_revenueratio,   
    pyd_lessrevenue,   
	pyd_payrevenue,   
    pyt_fee1,   
	pyt_fee2,   
    pyd_grossamount,   
	pyd_status,
	pyt_itemcode,
	del_reason
from #temp
order by asgn_type,asgn_id,pyd_number,audit_sequence

GO
GRANT EXECUTE ON  [dbo].[paydetailaudit_report_sp] TO [public]
GO
