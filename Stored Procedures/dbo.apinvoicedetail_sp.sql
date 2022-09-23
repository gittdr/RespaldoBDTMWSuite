SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[apinvoicedetail_sp] (@apv_number int) as
  Create table #temp (
				apv_number int not null,
				apd_number int not null,
				apd_asgn_type varchar(6)	not null,
				apd_asgn_id varchar(8)		not null,
				apd_pto_id varchar (8)		not null,
				apd_amount money			not null,
				apd_processed char (1) 		not null,
				std_number int 				null,
				sdm_itemcode varchar (6)    null,
				pyd_number int 				null,
				apd_asgn_id_drv varchar(8)	null,
				apd_asgn_id_trc varchar(8)	null,
				deleted_indicator   varchar(255) null,
				deduction_threshold money null DEFAULT 500, 
				apd_asgn_id_TRL varchar(8)	null,
				apd_asgn_id_CAR varchar(8)	null,
				apd_glnumber varchar (66) null,
				apd_glindex int null )
	
			  insert into #temp(
					 apv_number,   
			         apd_number,   
			         apd_asgn_type,   
			         apd_asgn_id,   
			         apd_pto_id,   
			         apd_amount,   
			         apd_processed,   
			         std_number,   
			         sdm_itemcode,   
			         pyd_number,
					 apd_glnumber,
					 apd_glindex)	
			  (SELECT apinvoicedetail.apv_number,   
			         apinvoicedetail.apd_number,   
			         apinvoicedetail.apd_asgn_type,   
			         apinvoicedetail.apd_asgn_id,   
			         apinvoicedetail.apd_pto_id,   
			         apinvoicedetail.apd_amount,   
			         apinvoicedetail.apd_processed,   
			         apinvoicedetail.std_number,   
			         apinvoicedetail.sdm_itemcode,   
			         apinvoicedetail.pyd_number,
					 apinvoicedetail.apd_glnumber,
					 apinvoicedetail.apd_glindex
			    FROM apinvoicedetail  
			   WHERE apinvoicedetail.apv_number = @apv_number ) 


		Update #temp set apd_asgn_id_drv = apd_asgn_id where apd_asgn_type = 'DRV'  
		Update #temp set apd_asgn_id_trc = apd_asgn_id where apd_asgn_type = 'TRC'  
		Update #temp set apd_asgn_id_car = apd_asgn_id where apd_asgn_type = 'CAR'  
		Update #temp set apd_asgn_id_trl = apd_asgn_id where apd_asgn_type = 'TRL'  

		Update #temp set deleted_indicator = 'Paydetail Deleted!' where not exists 
		(select * from paydetail c where #temp.pyd_number = c.pyd_number) and pyd_number > 0

		Update #temp set deleted_indicator = 'Deduction Deleted!' where not exists 
		(select * from standingdeduction c where #temp.std_number = c.std_number) and std_number > 0 


			Select	 apv_number,   
			         apd_number,   
			         apd_asgn_type,   
			         apd_asgn_id,   
			         apd_pto_id,   
			         apd_amount,   
			         apd_processed,   
			         std_number,   
			         sdm_itemcode,   
			         pyd_number ,
					 apd_asgn_id_drv,
					 apd_asgn_id_trc,
					 deleted_indicator,
					 deduction_threshold,
					 apd_asgn_id_trl,
					 apd_asgn_id_car,
					 apd_glnumber,
                     apd_glindex
			From	#temp

GO
GRANT EXECUTE ON  [dbo].[apinvoicedetail_sp] TO [public]
GO
