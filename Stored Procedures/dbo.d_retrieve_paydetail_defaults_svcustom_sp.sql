SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 create procedure [dbo].[d_retrieve_paydetail_defaults_svcustom_sp] (@ps_branch varchar(12) , @ps_lghtype1 varchar(6) , @ps_mpp_type1 varchar(6))
as

	create table #temp (brn_id varchar(12) not null,
						lgh_type1 varchar(6) not null,
						mpp_type1 varchar(6) not null,
						pyt_itemcode varchar(6) not null,
						pdd_quantity decimal(18,4) null,
						pdd_rate decimal(18,4) null)
	



	Insert into #temp
	select brn_id, lgh_type1,mpp_type1,pyt_itemcode,pdd_quantity,pdd_rate from paydetaildefaults
	where  brn_id = @ps_branch and lgh_type1 = 'UNK' and mpp_type1 = 'UNK'


	If @ps_lghtype1 <> 'UNK'
	Insert into #temp
	select brn_id, lgh_type1,mpp_type1,pyt_itemcode,pdd_quantity,pdd_rate from paydetaildefaults
	where  brn_id = @ps_branch and lgh_type1 = @ps_lghtype1 and mpp_type1 = 'UNK'

	If @ps_mpp_type1 <> 'UNK'
	Insert into #temp
	select brn_id, lgh_type1,mpp_type1,pyt_itemcode,pdd_quantity,pdd_rate from paydetaildefaults
	where  brn_id = @ps_branch and lgh_type1 = 'UNK' and mpp_type1 = @ps_mpp_type1

	 


	select brn_id, lgh_type1,mpp_type1,pyt_itemcode,pdd_quantity,pdd_rate from #temp

GO
GRANT EXECUTE ON  [dbo].[d_retrieve_paydetail_defaults_svcustom_sp] TO [public]
GO
