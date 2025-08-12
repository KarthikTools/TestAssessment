"""
Risk policy module that demonstrates external service dependencies.
In production, this would call real risk scoring services.
"""

from abc import ABC, abstractmethod
from typing import Tuple


class ExternalScoreClient(ABC):
    """Abstract interface for external risk scoring service."""
    
    @abstractmethod
    def get_score(self, payer_id: str, amount: float) -> int:
        """Get risk score from external service."""
        pass


class RiskPolicy:
    """Risk policy that uses external scoring service."""
    
    def __init__(self, client: ExternalScoreClient):
        self.client = client
    
    def decide(self, payer_id: str, amount: float) -> Tuple[int, str]:
        """
        Make risk decision based on external score.
        
        Args:
            payer_id: Customer identifier
            amount: Payment amount
            
        Returns:
            Tuple of (risk_score, decision)
            
        Raises:
            TimeoutError: If external service times out
        """
        score = self.client.get_score(payer_id, amount)
        
        if score >= 85:
            return score, "APPROVE"
        elif score >= 70:
            return score, "REVIEW"
        else:
            return score, "REJECT"


# Convenience function for backward compatibility
def decide(payer_id: str, amount: float, client: ExternalScoreClient) -> Tuple[int, str]:
    """Legacy function that creates policy and makes decision."""
    policy = RiskPolicy(client)
    return policy.decide(payer_id, amount)
