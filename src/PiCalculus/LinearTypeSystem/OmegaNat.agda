open import Relation.Binary.PropositionalEquality using (_≡_; refl; trans; cong)
open Relation.Binary.PropositionalEquality.≡-Reasoning
open import Relation.Nullary using (Dec; yes; no)
open import Function using (_∘_)

import Data.Nat.Base as ℕ
import Data.Unit.Base as Unit
import Data.Empty as Empty
import Data.Nat.Properties as ℕₚ
import Data.Vec.Base as Vec
import Data.Vec.Properties as Vecₚ
import Data.Vec.Relation.Unary.All as All
import Data.Vec.Relation.Binary.Pointwise.Inductive as Pointwise
import Data.Product as Product

open Empty using (⊥)
open Unit using (⊤; tt)
open Product using (Σ; Σ-syntax; _×_; _,_; proj₁; proj₂)
open ℕ using (ℕ; zero; suc)
open Vec using (Vec; []; _∷_)
open All using (All; []; _∷_)
open Pointwise using (Pointwise; []; _∷_)

open import PiCalculus.Function using (_⊗_; _&_)

module PiCalculus.LinearTypeSystem.OmegaNat where

data MType : Set where
  nonlin lin : MType

data ωℕ : MType → Set where
  n∙ : ℕ → ωℕ lin
  ω∙ : ωℕ nonlin

private
  variable
    n : ℕ
    M N : MType

pattern 0∙ = n∙ 0
pattern 1∙ = n∙ 1

ω0 : ωℕ M
ω0 {nonlin} = ω∙
ω0 {lin} = 0∙

ω1 : ωℕ M
ω1 {nonlin} = ω∙
ω1 {lin} = 1∙

_+_ : ωℕ M → ωℕ M → ωℕ M
n∙ x + n∙ y = n∙ (x ℕ.+ y)
ω∙ + ω∙ = ω∙

+-idˡ : ∀ x → ω0 {M} + x ≡ x
+-idˡ {nonlin} ω∙ = refl
+-idˡ {lin} (n∙ _) = refl

+-idʳ : ∀ x → x + ω0 {M} ≡ x
+-idʳ {nonlin} ω∙ = refl
+-idʳ {lin} (n∙ x) rewrite ℕₚ.+-identityʳ x = refl

+-comm : (x y : ωℕ M) → x + y ≡ y + x
+-comm (n∙ x) (n∙ y) rewrite ℕₚ.+-comm x y = refl
+-comm ω∙ ω∙ = refl

+-assoc : (x y z : ωℕ M) → (x + y) + z ≡ x + (y + z)
+-assoc (n∙ x) (n∙ y) (n∙ z) rewrite ℕₚ.+-assoc x y z = refl
+-assoc ω∙ ω∙ ω∙ = refl

_≤_ : ωℕ M → ωℕ M → Set
x ≤ y = Σ[ z ∈ _ ] z + x ≡ y

≤-+ʳ : {x y : ωℕ M} (z : ωℕ M) → x ≤ y → x ≤ (y + z)
≤-+ʳ {x = x} z (diff , refl) = (diff + z) , (begin
  (diff + z) + x
    ≡⟨ +-assoc _ _ _ ⟩
  diff + (z + x)
    ≡⟨ cong (_ +_) (+-comm _ _) ⟩
  diff + (x + z)
    ≡˘⟨ +-assoc _ _ _ ⟩
  (diff + x) + z
    ∎)

replicate : {Ms : Vec MType n} → (∀ {M} → ωℕ M) → All ωℕ Ms
replicate {Ms = []} f = []
replicate {Ms = M ∷ Ms} f = f {M} ∷ replicate f

_+ᵥ_ : {Ms : Vec MType n} → All ωℕ Ms → All ωℕ Ms → All ωℕ Ms
[] +ᵥ [] = []
(x ∷ xs) +ᵥ (y ∷ ys) = x + y ∷ xs +ᵥ ys

+ᵥ-idˡ : {Ms : Vec MType n} (m : All ωℕ Ms) → replicate ω0 +ᵥ m ≡ m
+ᵥ-idˡ [] = refl
+ᵥ-idˡ (x ∷ m) rewrite +ᵥ-idˡ m | +-idˡ x = refl

+ᵥ-idʳ : {Ms : Vec MType n} (m : All ωℕ Ms) → m +ᵥ replicate ω0 ≡ m
+ᵥ-idʳ [] = refl
+ᵥ-idʳ (x ∷ m) rewrite +ᵥ-idʳ m | +-idʳ x = refl

+ᵥ-assoc : {Ms : Vec MType n} (m n l : All ωℕ Ms) → (m +ᵥ n) +ᵥ l ≡ m +ᵥ (n +ᵥ l)
+ᵥ-assoc [] [] [] = refl
+ᵥ-assoc (x ∷ m) (y ∷ n) (z ∷ l) rewrite +ᵥ-assoc m n l | +-assoc x y z = refl

+ᵥ-comm : {Ms : Vec MType n} (m n : All ωℕ Ms) → m +ᵥ n ≡ n +ᵥ m
+ᵥ-comm [] [] = refl
+ᵥ-comm (x ∷ m) (y ∷ n) rewrite +ᵥ-comm m n | +-comm x y = refl

_≤ᵥ_ : {Ms : Vec MType n} → All ωℕ Ms → All ωℕ Ms → Set
m ≤ᵥ n = Σ[ l ∈ _ ] l +ᵥ m ≡ n

≤ᵥ-refl : {Ms : Vec MType n} (m : All ωℕ Ms) → m ≤ᵥ m
≤ᵥ-refl m = replicate ω0 , +ᵥ-idˡ _

≤ᵥ-+ᵥʳ : {Ms : Vec MType n} {m n : All ωℕ Ms} (l : All ωℕ Ms) → m ≤ᵥ n → m ≤ᵥ (n +ᵥ l)
≤ᵥ-+ᵥʳ {m = m} l (diff , refl) = (diff +ᵥ l) , (begin
  (diff +ᵥ l) +ᵥ m
    ≡⟨ +ᵥ-assoc _ _ _ ⟩
  diff +ᵥ (l +ᵥ m)
    ≡⟨ cong (_ +ᵥ_) (+ᵥ-comm _ _) ⟩
  diff +ᵥ (m +ᵥ l)
    ≡˘⟨ +ᵥ-assoc _ _ _ ⟩
  (diff +ᵥ m) +ᵥ l
    ∎)
