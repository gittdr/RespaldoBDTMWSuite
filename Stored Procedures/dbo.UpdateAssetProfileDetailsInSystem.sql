SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UpdateAssetProfileDetailsInSystem]
	@EffectiveDate DateTime
AS
BEGIN

CREATE TABLE #tempAssetProfileLog(
	id int NOT NULL,
	res_id varchar(13) NOT NULL,
	res_type varchar(50) NOT NULL,
	lbl_category varchar(50) NOT NULL,
	lbl_value varchar(50) NOT NULL)

	insert into #tempAssetProfileLog
		select id, res_id, res_type, lbl_category, lbl_value 
		from AssetProfileLog 
		where effective < @EffectiveDate and appliedon is NULL
		order by id

	Declare @currentId int, @resId varchar(13), @resType varchar(50), @lbl_category varchar(50), @lbl_value varchar(50)
	
	select top 1 @currentId = id, @resId = res_id, @resType = res_type, @lbl_category = lbl_category, @lbl_value = lbl_value
	from #tempAssetProfileLog
	order by id
		
	while @currentId <> -1
	begin
	begin tran

		update AssetProfileLog
		set appliedbysqljob = 'I'
		where id = @currentId		

		if @resType = 'Driver'
		begin
			update manpowerprofile
			set
				mpp_type1 = (case when @lbl_category = 'DrvType1' then @lbl_value else mpp_type1 end),
				mpp_type2 = (case when @lbl_category = 'DrvType2' then @lbl_value else mpp_type2 end),
				mpp_type3 = (case when @lbl_category = 'DrvType3' then @lbl_value else mpp_type3 end),
				mpp_type4 = (case when @lbl_category = 'DrvType4' then @lbl_value else mpp_type4 end),
				mpp_company = (case when @lbl_category = 'Company' then @lbl_value else mpp_company end),
				mpp_division = (case when @lbl_category = 'Division' then @lbl_value else mpp_division end),
				mpp_fleet = (case when @lbl_category = 'Fleet' then @lbl_value else mpp_fleet end),
				mpp_terminal = (case when @lbl_category = 'Terminal' then @lbl_value else mpp_terminal end),
				mpp_teamleader = (case when @lbl_category = 'TeamLeader' then @lbl_value else mpp_teamleader end),
				mpp_domicile = (case when @lbl_category = 'Domicile' then @lbl_value else mpp_domicile end)
			where
				mpp_id = @resId
		end
		
		if @resType = 'Tractor'
		begin		
			update tractorprofile
			set
				trc_type1 = (case when @lbl_category = 'TrcType1' then @lbl_value else trc_type1 end),
				trc_type2 = (case when @lbl_category = 'TrcType2' then @lbl_value else trc_type2 end),
				trc_type3 = (case when @lbl_category = 'TrcType3' then @lbl_value else trc_type3 end),
				trc_type4 = (case when @lbl_category = 'TrcType4' then @lbl_value else trc_type4 end),
				trc_company = (case when @lbl_category = 'Company' then @lbl_value else trc_company end),
				trc_division = (case when @lbl_category = 'Division' then @lbl_value else trc_division end),
				trc_fleet = (case when @lbl_category = 'Fleet' then @lbl_value else trc_fleet end),
				trc_terminal = (case when @lbl_category = 'Terminal' then @lbl_value else trc_terminal end)
			where
				trc_number = @resId			
		end
		
		if @resType = 'Trailer'
		begin		
			update trailerprofile
			set
				trl_type1 = (case when @lbl_category = 'TrlType1' then @lbl_value else trl_type1 end),
				trl_type2 = (case when @lbl_category = 'TrlType2' then @lbl_value else trl_type2 end),
				trl_type3 = (case when @lbl_category = 'TrlType3' then @lbl_value else trl_type3 end),
				trl_type4 = (case when @lbl_category = 'TrlType4' then @lbl_value else trl_type4 end),
				trl_company = (case when @lbl_category = 'Company' then @lbl_value else trl_company end),
				trl_division = (case when @lbl_category = 'Division' then @lbl_value else trl_division end),
				trl_fleet = (case when @lbl_category = 'Fleet' then @lbl_value else trl_fleet end),
				trl_terminal = (case when @lbl_category = 'Terminal' then @lbl_value else trl_terminal end)
			where
				trl_id = @resId
		end
		
		if @resType = 'Company'
		begin
			update company
			set
				cmp_revtype1 = (case when @lbl_category = 'RevType1' then @lbl_value else cmp_revtype1 end),
				cmp_revtype2 = (case when @lbl_category = 'RevType2' then @lbl_value else cmp_revtype2 end),
				cmp_revtype3 = (case when @lbl_category = 'RevType3' then @lbl_value else cmp_revtype3 end),
				cmp_revtype4 = (case when @lbl_category = 'RevType4' then @lbl_value else cmp_revtype4 end),
				cmp_othertype1 = (case when @lbl_category = 'OtherTypes1' then @lbl_value else cmp_othertype1 end),
				cmp_othertype2 = (case when @lbl_category = 'OtherTypes2' then @lbl_value else cmp_othertype2 end)
			where 
				cmp_id = @resId
		end
		
		if @@error <> 0
		begin
			rollback
			DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
			SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()

			update AssetProfileLog
			set appliedbysqljob = NULL
			where id = @currentId		

			RAISERROR(@ErrMsg, @ErrSeverity, 1)
		end
		else
		begin	
			commit
			update AssetProfileLog
			set appliedbysqljob = 'Y', appliedon = GetDate()
			where id = @currentId		
		end
		
		if (select count(*) from #tempAssetProfileLog where id > @currentId) = 0
		begin
			select @currentId = -1
		end
		else
		begin
			select top 1 @currentId = id, @resId = res_id, @resType = res_type, @lbl_category = lbl_category, @lbl_value = lbl_value
			from #tempAssetProfileLog
			where id > @currentId
		end		
	end
	drop table #tempAssetProfileLog
END
GO
GRANT EXECUTE ON  [dbo].[UpdateAssetProfileDetailsInSystem] TO [public]
GO
