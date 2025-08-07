module charitha_addr::ImpermanentLossInsurance {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;

    struct InsurancePolicy has store, key {
        initial_deposit: u64,        
        premium_paid: u64,          
        coverage_percentage: u64,    
        policy_start_time: u64,      
        is_active: bool,             
        total_claims: u64,           
    }

    
    public fun purchase_insurance(
        liquidity_provider: &signer, 
        deposit_amount: u64, 
        premium: u64, 
        coverage_percentage: u64
    ) {
         assert!(coverage_percentage <= 80, 1001);
        assert!(coverage_percentage > 0, 1002);
        assert!(premium > 0, 1003);
        assert!(deposit_amount > 0, 1004);

        
        let premium_payment = coin::withdraw<AptosCoin>(liquidity_provider, premium);
        coin::deposit<AptosCoin>(@charitha_addr, premium_payment);

       
        let policy = InsurancePolicy {
            initial_deposit: deposit_amount,
            premium_paid: premium,
            coverage_percentage,
            policy_start_time: timestamp::now_seconds(),
            is_active: true,
            total_claims: 0,
        };

        move_to(liquidity_provider, policy);
    }

  
    public fun claim_compensation(
        liquidity_provider: &signer, 
        current_value: u64, 
        loss_amount: u64
    ) acquires InsurancePolicy {
        let provider_address = signer::address_of(liquidity_provider);
        let policy = borrow_global_mut<InsurancePolicy>(provider_address);
        
   
        assert!(policy.is_active, 2001);
        assert!(current_value < policy.initial_deposit, 2002);
        assert!(loss_amount > 0, 2003);
        assert!(loss_amount <= (policy.initial_deposit - current_value), 2004);

       
        let compensation = (loss_amount * policy.coverage_percentage) / 100;

     
        policy.total_claims = policy.total_claims + compensation;
    }

}
