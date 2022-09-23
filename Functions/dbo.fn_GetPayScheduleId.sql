SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetPayScheduleId]
(
	@AssetType		INT,
	@actg_type		char(1),
	@company		varchar(255),
	@division		varchar(255),
	@terminal		varchar(255),
	@fleet			varchar(255),
	@type1			varchar(255),
	@type2			varchar(255),
	@type3			varchar(255),
	@type4			varchar(255),
    @mode int
) 
RETURNS int

AS
/**
*
* NAME:
* dbo.fn_GetPayScheduleId
*
* TYPE:
* Function
*
* DESCRIPTION:
* Function to get the payschedule ID for an asset.
* This should ba a parallel piece of code to backoffice code in object::method
* If you make changes here, make parallel changes there.
*
* RETURNS:
*
* RESULT SETS:
*
* PARAMETERS:
AssetType is a numeric value
	1	DRV
	2	CAR
	3	TRC
	4	TRL
	5	PTO
	6	TPY

	Sample Execution:

declare @p int
exec @p = fn_GetPayScheduleId 1, 'A', 'INC', 'UNK', 'UNK', 'UNK', 'UNK', 'CLE', 'UNK', 'UNK'
select @p

declare @p int
exec @p = fn_GetPayScheduleId 1, 'P', 'UNK', 'UNK', 'UNK', 'UNK', 'UNK', 'UNK', 'UNK', 'UNK'
select @p


*
* REVISION HISTORY:
* 2014/10/17 | PTS 83249 | vjh	  - create function for use in trigger on assets
**/
BEGIN
  declare @return	int
  
  declare @temp  table (
    PayScheduleId  int,
    AssetType      int,
    AccountingType char(1),
    Company        varchar(255),
    Division       varchar(255),
    Terminal       varchar(255),
    Fleet          varchar(255),
    Type1          varchar(255),
    Type2          varchar(255),
    Type3          varchar(255),
    Type4          varchar(255)
  )
  
  if @actg_type = 'N' return null
  
  insert @temp(PayScheduleId, AssetType, AccountingType, Company, Division, Terminal, Fleet, Type1, Type2, Type3, Type4)
    select 
      ps.PayScheduleId, 
      ps.AssetType, 
      ps.AccountingType, 
      case when psr.Company is null or psr.Company = '' then 'UNK' else psr.Company end as Company,
      case when psr.Division is null or psr.Division = '' then 'UNK' else psr.Division end as Division,
      case when psr.Terminal is null or psr.Terminal = '' then 'UNK' else psr.Terminal end as Division,
      case when psr.Fleet is null or psr.Fleet = '' then 'UNK' else psr.Fleet end as Fleet,
      case when psr.Type1 is null or psr.Type1 = '' then 'UNK' else psr.Type1 end as Type1,
      case when psr.Type2 is null or psr.Type2 = '' then 'UNK' else psr.Type2 end as Type2,
      case when psr.Type3 is null or psr.Type3 = '' then 'UNK' else psr.Type3 end as Type3,
      case when psr.Type4 is null or psr.Type4 = '' then 'UNK' else psr.Type4 end as Type4
    from dbo.payschedules ps left join
       (select 
          PayScheduleId, 
          max(case when LabelDefinition = 'Company' then Value else '' end) as Company,
          max(case when LabelDefinition = 'Division' then Value else '' end) as Division,
          max(case when LabelDefinition = 'Terminal' then Value else '' end) as Terminal,
          max(case when LabelDefinition = 'Fleet' then Value else '' end) as Fleet,
          max(case when LabelDefinition like '%type1' then Value else '' end) as Type1,
          max(case when LabelDefinition like '%type2' then Value else '' end) as Type2,
          max(case when LabelDefinition like '%type3' then Value else '' end) as Type3,
          max(case when LabelDefinition like '%type4' then Value else '' end) as Type4
        from dbo.PayScheduleRestrictions
        group by PayScheduleId
       ) psr
       on ps.PayScheduleId = psr.PayScheduleId
    where 
    	(ps.AssetType = @AssetType or ps.AssetType = 0) and
    	(ps.AccountingType = @actg_type or ps.AccountingType = 'X')
        and ps.[Mode] = @mode
  
  If @AssetType = 2 or @AssetType = 6 
  begin
  	--carrier (2) and third party(6) do not use CDTF
  	select top 1 @return = PayScheduleId 
    from @temp
  	where 
  		(Type1 = @type1 or type1='UNK') and
  		(Type2 = @type2 or type2='UNK') and
  		(Type3 = @type3 or type3='UNK') and
  		(Type4 = @type4 or type4='UNK')
  	order by  		
  		AssetType desc,
  		case Type1 when 'UNK' then 0 else 1 end desc,
  		case Type2 when 'UNK' then 0 else 1 end desc,
  		case Type3 when 'UNK' then 0 else 1 end desc,
  		case Type4 when 'UNK' then 0 else 1 end desc,
		case AccountingType when 'X' then 0 else 1 end desc
  end 
  else 
  begin
  	--the rest of the assets use CDTF
  	select top 1 @return = PayScheduleId 
    from @temp
  	where 
  		(type1 = @type1 or type1='UNK') and
  		(type2 = @type2 or type2='UNK') and
  		(type3 = @type3 or type3='UNK') and
  		(type4 = @type4 or type4='UNK') and
  		(Company = @Company or Company='UNK') and
  		(Division = @Division or Division='UNK') and
  		(Terminal = @Terminal or Terminal='UNK') and
  		(Fleet = @Fleet or Fleet='UNK')
  	order by  		
  		AssetType desc,
  		case Company when 'UNK' then 0 else 1 end desc,
  		case Division when 'UNK' then 0 else 1 end desc,
  		case Terminal when 'UNK' then 0 else 1 end desc,
  		case Fleet when 'UNK' then 0 else 1 end desc,
  		case Type1 when 'UNK' then 0 else 1 end desc,
  		case Type2 when 'UNK' then 0 else 1 end desc,
  		case Type3 when 'UNK' then 0 else 1 end desc,
  		case Type4 when 'UNK' then 0 else 1 end desc,
		case AccountingType when 'X' then 0 else 1 end desc
  end
  
  RETURN isnull(@return, -1)
END

GO
GRANT EXECUTE ON  [dbo].[fn_GetPayScheduleId] TO [public]
GO
